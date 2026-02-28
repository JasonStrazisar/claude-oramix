import SwiftUI

struct SpecautomatixView: View {
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
                focusSearch: $focusSearch
            )
        } content: {
            if editingSpec != nil {
                SpecEditorView(spec: editingSpecBinding, onDelete: handleDelete)
            } else {
                Text("Sélectionnez une spec dans la sidebar")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } detail: {
            if let spec = editingSpec {
                ScorePanelView(spec: spec)
            } else {
                Text("Sélectionnez une spec dans la sidebar")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
