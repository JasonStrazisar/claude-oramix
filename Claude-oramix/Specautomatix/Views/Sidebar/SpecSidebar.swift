import SwiftUI

struct SpecSidebar: View {
    @ObservedObject var store: SpecStore
    @Binding var selectedSpecId: UUID?

    var body: some View {
        Group {
            if store.specs.isEmpty {
                Text("Aucune spec. Cliquez + pour commencer.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(selection: $selectedSpecId) {
                    ForEach(SpecSidebar.sorted(store.specs)) { spec in
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
    }

    static func sorted(_ specs: [Spec]) -> [Spec] {
        specs.sorted { $0.updatedAt > $1.updatedAt }
    }
}
