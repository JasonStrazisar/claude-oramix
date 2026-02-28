import SwiftUI

struct SpecSidebar: View {
    @ObservedObject var store: SpecStore
    @Binding var selectedSpecId: UUID?
    @Binding var searchText: String
    @Binding var focusSearch: Bool

    @FocusState private var isSearchFocused: Bool

    var filteredSpecs: [Spec] {
        let sorted = SpecSidebar.sorted(store.specs)
        if searchText.isEmpty { return sorted }
        return sorted.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("Rechercher...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding(8)
                .focused($isSearchFocused)

            if store.specs.isEmpty {
                Text("Aucune spec. Cliquez + pour commencer.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if filteredSpecs.isEmpty {
                Text("Aucun résultat pour \(searchText)")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedSpecId) {
                    ForEach(filteredSpecs) { spec in
                        SpecRowView(spec: spec)
                            .tag(spec.id)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    let newSpec = Spec(title: "New Spec")
                    store.add(newSpec)
                    selectedSpecId = newSpec.id
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onChange(of: focusSearch) { _, newValue in
            if newValue {
                isSearchFocused = true
                focusSearch = false
            }
        }
    }

    static func sorted(_ specs: [Spec]) -> [Spec] {
        specs.sorted { $0.updatedAt > $1.updatedAt }
    }
}
