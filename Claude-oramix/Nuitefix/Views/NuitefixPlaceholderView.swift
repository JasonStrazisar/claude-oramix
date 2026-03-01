import SwiftUI

struct NuitefixView: View {
    @Binding var activeAgent: Agent

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                AgentSelectorView(activeAgent: $activeAgent)
                Divider()
                    .opacity(0.6)
                Spacer()
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .navigationSplitViewColumnWidth(272)
        } detail: {
            placeholderContent
        }
    }

    @ViewBuilder
    private var placeholderContent: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color.theme.accentLight)
                        .frame(width: 96, height: 96)

                    Image(systemName: "dog.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color.theme.accent)
                }

                VStack(spacing: 8) {
                    Text("Nuitéfix")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(Color.theme.textPrimary)

                    Text("Le petit chien fidèle qui part la nuit chercher tes PRs.")
                        .font(.body)
                        .foregroundColor(Color.theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                }

                Text("Arriving in Phase 3 — the dog is still asleep")
                    .font(.callout)
                    .foregroundColor(Color.theme.textTertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.theme.accentLight)
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}
