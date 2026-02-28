import SwiftUI

struct MetadataSectionView: View {
    @Binding var metadata: SpecMetadata

    @State private var labelsText: String = ""
    @State private var dependenciesText: String = ""

    var body: some View {
        GroupBox(label: Text("Metadata").font(.headline)) {
            Form {
                Stepper("Estimate: \(metadata.estimate ?? 0) SP",
                        value: Binding(
                            get: { metadata.estimate ?? 0 },
                            set: { metadata.estimate = $0 }
                        ),
                        in: 0...5)

                TextField("Labels (comma-separated)", text: $labelsText)
                    .onSubmit {
                        metadata.labels = labelsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    }
                    .onChange(of: labelsText) {
                        metadata.labels = labelsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    }

                TextField("Epic", text: Binding(
                    get: { metadata.epic ?? "" },
                    set: { metadata.epic = $0.isEmpty ? nil : $0 }
                ))

                TextField("Dependencies (comma-separated)", text: $dependenciesText)
                    .onChange(of: dependenciesText) {
                        metadata.dependencies = dependenciesText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    }

                TextField("Merge-safe declaration", text: Binding(
                    get: { metadata.mergeSafeDeclaration ?? "" },
                    set: { metadata.mergeSafeDeclaration = $0.isEmpty ? nil : $0 }
                ))
            }
        }
        .onAppear {
            labelsText = metadata.labels.joined(separator: ", ")
            dependenciesText = metadata.dependencies.joined(separator: ", ")
        }
    }
}
