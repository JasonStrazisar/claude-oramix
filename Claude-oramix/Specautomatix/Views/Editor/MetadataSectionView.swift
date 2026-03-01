import SwiftUI

struct MetadataSectionView: View {
    @Binding var metadata: SpecMetadata

    @State private var labelsText: String = ""
    @State private var dependenciesText: String = ""

    var body: some View {
        EditorSection(icon: "tag", title: "Metadata") {
            VStack(alignment: .leading, spacing: 12) {
                metaRow(label: "Estimate") {
                    HStack(spacing: 10) {
                        Text("\(metadata.estimate ?? 0) SP")
                            .font(.system(.callout, design: .rounded).weight(.semibold))
                            .foregroundColor(Color.theme.textPrimary)
                            .frame(width: 44, alignment: .leading)

                        Stepper("", value: Binding(
                            get: { metadata.estimate ?? 0 },
                            set: { metadata.estimate = $0 }
                        ), in: 0...13)
                        .labelsHidden()
                    }
                }

                metaRow(label: "Labels") {
                    TextField("feature, performance, …", text: $labelsText)
                        .font(.callout)
                        .textFieldStyle(.plain)
                        .onSubmit { syncLabels() }
                        .onChange(of: labelsText) { syncLabels() }
                }

                metaRow(label: "Epic") {
                    TextField("Epic name", text: Binding(
                        get: { metadata.epic ?? "" },
                        set: { metadata.epic = $0.isEmpty ? nil : $0 }
                    ))
                    .font(.callout)
                    .textFieldStyle(.plain)
                }

                metaRow(label: "Dependencies") {
                    TextField("P1-001, P1-002, …", text: $dependenciesText)
                        .font(.callout)
                        .textFieldStyle(.plain)
                        .onChange(of: dependenciesText) { syncDependencies() }
                }

                metaRow(label: "Merge-safe") {
                    TextField("Declaration", text: Binding(
                        get: { metadata.mergeSafeDeclaration ?? "" },
                        set: { metadata.mergeSafeDeclaration = $0.isEmpty ? nil : $0 }
                    ))
                    .font(.callout)
                    .textFieldStyle(.plain)
                }
            }
        }
        .onAppear {
            labelsText = metadata.labels.joined(separator: ", ")
            dependenciesText = metadata.dependencies.joined(separator: ", ")
        }
    }

    @ViewBuilder
    private func metaRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.theme.textTertiary)
                .frame(width: 84, alignment: .trailing)

            content()
                .foregroundColor(Color.theme.textPrimary)
        }
    }

    private func syncLabels() {
        metadata.labels = labelsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    private func syncDependencies() {
        metadata.dependencies = dependenciesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}
