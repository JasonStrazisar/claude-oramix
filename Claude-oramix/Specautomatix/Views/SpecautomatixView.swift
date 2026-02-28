import SwiftUI

struct SpecautomatixView: View {
    @EnvironmentObject private var store: SpecStore
    @State private var selectedSpecId: UUID?
    @State private var editingSpec: Spec?

    var body: some View {
        NavigationSplitView {
            SpecSidebar(store: store, selectedSpecId: $selectedSpecId)
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
}
