import SwiftUI

struct SpecautomatixView: View {
    @Binding var activeAgent: Agent
    @EnvironmentObject private var store: SpecStore
    @State private var selectedSpecId: UUID?
    @State private var editingSpec: Spec?
    @State private var searchText: String = ""
    @State private var focusSearch: Bool = false

    var filteredSpecs: [Spec] {
        let sorted = SpecSidebar.sorted(store.specs)
        if searchText.isEmpty { return sorted }
        return sorted.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationSplitView {
            SpecSidebar(
                store: store,
                selectedSpecId: $selectedSpecId,
                searchText: $searchText,
                focusSearch: $focusSearch,
                activeAgent: $activeAgent
            )
            .navigationSplitViewColumnWidth(272)
        } content: {
            if editingSpec != nil {
                SpecEditorView(spec: editingSpecBinding, onDelete: handleDelete)
            } else {
                editorEmptyState
            }
        } detail: {
            if let spec = editingSpec {
                ScorePanelView(spec: spec)
            } else {
                scorePanelEmptyState
            }
        }
        .onAppear {
            loadMockDataIfNeeded()
        }
        .onChange(of: selectedSpecId) { _, newId in
            editingSpec = store.specs.first(where: { $0.id == newId })
        }
        .overlay(alignment: .topLeading) {
            keyboardShortcutsView
                .frame(width: 0, height: 0)
                .opacity(0)
                .allowsHitTesting(false)
        }
    }

    // MARK: - Empty states

    @ViewBuilder
    private var editorEmptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 36))
                .foregroundColor(Color.theme.textTertiary)

            Text("No spec selected")
                .font(.system(.title3, design: .default).weight(.semibold))
                .foregroundColor(Color.theme.textSecondary)

            Text("Select a spec from the sidebar, or press ⌘N to create one.")
                .font(.callout)
                .foregroundColor(Color.theme.textTertiary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            Button {
                createNewSpec()
            } label: {
                Label("New Spec", systemImage: "plus.circle.fill")
                    .font(.callout.weight(.medium))
                    .foregroundColor(Color.theme.accent)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.theme.accentLight)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }

    @ViewBuilder
    private var scorePanelEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal")
                .font(.system(size: 32))
                .foregroundColor(Color.theme.textTertiary)

            Text("Score panel")
                .font(.system(.callout, design: .default).weight(.semibold))
                .foregroundColor(Color.theme.textTertiary)

            Text("Select a spec to see its score.")
                .font(.caption)
                .foregroundColor(Color.theme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.surface)
    }

    // MARK: - Keyboard shortcuts (hidden buttons)

    @ViewBuilder
    private var keyboardShortcutsView: some View {
        VStack {
            Button("") { createNewSpec() }
                .keyboardShortcut("n", modifiers: .command)
            Button("") { focusSearch = true }
                .keyboardShortcut("f", modifiers: .command)
            Button("") { selectPrevious() }
                .keyboardShortcut(.upArrow, modifiers: .command)
            Button("") { selectNext() }
                .keyboardShortcut(.downArrow, modifiers: .command)
        }
    }

    // MARK: - Private

    private var editingSpecBinding: Binding<Spec> {
        Binding(
            get: { self.editingSpec ?? Spec(title: "") },
            set: { updated in
                var withTimestamp = updated
                withTimestamp.updatedAt = Date()
                self.editingSpec = withTimestamp
                self.store.update(withTimestamp)
            }
        )
    }

    private func loadMockDataIfNeeded() {
        if store.specs.isEmpty {
            MockData.specs.forEach { store.add($0) }
        }
        if selectedSpecId == nil {
            let firstId = SpecSidebar.sorted(store.specs).first?.id
            selectedSpecId = firstId
            editingSpec = store.specs.first(where: { $0.id == firstId })
        }
    }

    private func handleDelete(_ id: UUID) {
        store.delete(id)
        if selectedSpecId == id {
            let nextId = SpecSidebar.sorted(store.specs).first?.id
            selectedSpecId = nextId
            editingSpec = store.specs.first(where: { $0.id == nextId })
        }
    }

    private func createNewSpec() {
        let newSpec = Spec(title: "New Spec")
        store.add(newSpec)
        selectedSpecId = newSpec.id
    }

    private func selectPrevious() {
        let specs = filteredSpecs
        guard !specs.isEmpty else { return }
        if let currentId = selectedSpecId,
           let index = specs.firstIndex(where: { $0.id == currentId }),
           index > 0 {
            selectedSpecId = specs[index - 1].id
        } else if selectedSpecId == nil {
            selectedSpecId = specs.first?.id
        }
    }

    private func selectNext() {
        let specs = filteredSpecs
        guard !specs.isEmpty else { return }
        if let currentId = selectedSpecId,
           let index = specs.firstIndex(where: { $0.id == currentId }),
           index < specs.count - 1 {
            selectedSpecId = specs[index + 1].id
        } else if selectedSpecId == nil {
            selectedSpecId = specs.first?.id
        }
    }
}
