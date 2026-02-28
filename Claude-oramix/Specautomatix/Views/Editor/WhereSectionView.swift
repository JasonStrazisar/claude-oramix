import SwiftUI

struct WhereSectionView: View {
    @Binding var fileTargets: [FileTarget]

    var body: some View {
        GroupBox(label: Text("Where (Files)").font(.headline)) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach($fileTargets) { $target in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            TextField("path/to/File.swift", text: $target.path)
                                .font(.system(.body, design: .monospaced))
                            TextField("Description", text: $target.description)
                        }
                        Button(action: { removeTarget(target) }) {
                            Image(systemName: "minus.circle")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    Divider()
                }

                Button(action: addTarget) {
                    Label("Add file", systemImage: "plus")
                }
            }
        }
    }

    private func addTarget() {
        fileTargets.append(FileTarget())
    }

    private func removeTarget(_ target: FileTarget) {
        fileTargets.removeAll { $0.id == target.id }
    }
}
