import SwiftUI

/// Reusable section wrapper for the spec editor.
/// Replaces GroupBox with a cleaner, icon-headed card layout.
struct EditorSection<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.theme.accent)
                    .frame(width: 18, height: 18)

                Text(title)
                    .font(.system(.title3, design: .default).weight(.semibold))
                    .foregroundColor(Color.theme.textPrimary)
            }

            // Content — indented under the icon
            content()
                .padding(.leading, 26)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }
}
