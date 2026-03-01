import SwiftUI

struct SpecSidebar: View {
    @ObservedObject var store: SpecStore
    @Binding var selectedSpecId: UUID?
    @Binding var searchText: String
    @Binding var focusSearch: Bool
    @Binding var activeAgent: Agent

    @FocusState private var isSearchFocused: Bool

    var filteredSpecs: [Spec] {
        let sorted = SpecSidebar.sorted(store.specs)
        if searchText.isEmpty { return sorted }
        return sorted.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            AgentSelectorView(activeAgent: $activeAgent)

            Divider()
                .opacity(0.6)

            searchField

            Divider()
                .opacity(0.6)

            specList
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .toolbar {
            ToolbarItem {
                Button {
                    let newSpec = Spec(title: "New Spec")
                    store.add(newSpec)
                    selectedSpecId = newSpec.id
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundColor(Color.theme.accent)
                }
                .help("New Spec (⌘N)")
            }
        }
        .onChange(of: focusSearch) { _, newValue in
            if newValue {
                isSearchFocused = true
                focusSearch = false
            }
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.theme.textTertiary)

            TextField("Search specs…", text: $searchText)
                .textFieldStyle(.plain)
                .font(.system(.body))
                .focused($isSearchFocused)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.theme.surface)
    }

    @ViewBuilder
    private var specList: some View {
        if store.specs.isEmpty {
            emptyState(
                icon: "doc.text.magnifyingglass",
                title: "No specs yet",
                subtitle: "Press ⌘N to create your first spec."
            )
        } else if filteredSpecs.isEmpty {
            emptyState(
                icon: "magnifyingglass",
                title: "No results",
                subtitle: "Nothing matches \"\(searchText)\""
            )
        } else {
            List(selection: $selectedSpecId) {
                ForEach(filteredSpecs) { spec in
                    SpecRowView(spec: spec)
                        .tag(spec.id)
                }
            }
            .listStyle(.sidebar)
        }
    }

    @ViewBuilder
    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color.theme.textTertiary)

            Text(title)
                .font(.system(.callout, design: .default).weight(.semibold))
                .foregroundColor(Color.theme.textSecondary)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(Color.theme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    static func sorted(_ specs: [Spec]) -> [Spec] {
        specs.sorted { $0.updatedAt > $1.updatedAt }
    }
}
