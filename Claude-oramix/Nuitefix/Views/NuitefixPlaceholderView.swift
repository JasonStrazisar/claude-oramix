import SwiftUI

struct NuitefixPlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("Nuitéfix")
                .font(.largeTitle)
                .bold()

            Text("Le petit chien fidèle qui part la nuit chercher tes PRs.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("Coming in Phase 3")
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}
