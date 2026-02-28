import SwiftUI

struct AcceptanceCriteriaRowView: View {
    @Binding var criterion: AcceptanceCriteria
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(typeColor)
                    .frame(width: 10, height: 10)
                Picker("Type", selection: $criterion.type) {
                    ForEach(CriteriaType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .labelsHidden()
                .frame(width: 120)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }

            TextField("Given...", text: $criterion.given)
            TextField("When...", text: $criterion.when_)
            TextField("Then...", text: $criterion.then_)
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }

    private var typeColor: Color {
        switch criterion.type {
        case .happyPath: return .green
        case .errorCase: return .red
        case .edgeCase: return .orange
        }
    }
}
