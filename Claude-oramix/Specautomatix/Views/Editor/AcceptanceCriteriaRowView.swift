import SwiftUI

struct AcceptanceCriteriaRowView: View {
    @Binding var criterion: AcceptanceCriteria
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Type header
            HStack(spacing: 8) {
                Circle()
                    .fill(typeColor)
                    .frame(width: 8, height: 8)

                Picker("Type", selection: $criterion.type) {
                    ForEach(CriteriaType.allCases, id: \.self) { type in
                        Text(typeLabel(type)).tag(type)
                    }
                }
                .labelsHidden()
                .frame(width: 130)

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(Color.theme.textTertiary)
                }
                .buttonStyle(.plain)
            }

            // GWT fields
            VStack(alignment: .leading, spacing: 6) {
                gwtField(prefix: "Given", placeholder: "initial context…", text: $criterion.given)
                gwtField(prefix: "When",  placeholder: "the action taken…", text: $criterion.when_)
                gwtField(prefix: "Then",  placeholder: "the expected result…", text: $criterion.then_)
            }
        }
        .padding(12)
        .background(Color.theme.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(typeColor.opacity(0.3), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func gwtField(prefix: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(prefix)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.theme.textTertiary)
                .frame(width: 34, alignment: .trailing)

            TextField(placeholder, text: text)
                .font(.callout)
                .textFieldStyle(.plain)
                .foregroundColor(Color.theme.textPrimary)
        }
    }

    private var typeColor: Color {
        switch criterion.type {
        case .happyPath: return Color.theme.gradeAAccent
        case .errorCase: return Color.theme.destructive
        case .edgeCase:  return Color.theme.gradeCAccent
        }
    }

    private func typeLabel(_ type: CriteriaType) -> String {
        switch type {
        case .happyPath: return "Happy Path"
        case .errorCase: return "Error Case"
        case .edgeCase:  return "Edge Case"
        }
    }
}
