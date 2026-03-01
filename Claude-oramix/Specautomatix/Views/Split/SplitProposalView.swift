import SwiftUI

struct SplitProposalView: View {
    @Binding var proposals: [SplitProposal]
    let onConfirm: ([SplitProposal]) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(proposals.indices, id: \.self) { index in
                        SplitProposalCard(proposal: $proposals[index], number: index + 1)
                    }
                }
            }

            actionButtons
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 420)
        .background(Color.theme.background)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Split Spec into Sub-specs")
                .font(.title2.weight(.bold))
                .foregroundColor(Color.theme.textPrimary)

            Text("Review and edit the proposed sub-specs before confirming.")
                .font(.callout)
                .foregroundColor(Color.theme.textSecondary)
        }
    }

    // MARK: - Action buttons

    private var actionButtons: some View {
        HStack {
            Button("Cancel", role: .cancel) {
                onCancel()
            }

            Spacer()

            Button("Confirm Split") {
                onConfirm(proposals)
            }
            .buttonStyle(.borderedProminent)
            .disabled(proposals.isEmpty)
        }
    }
}

// MARK: - SplitProposalCard

private struct SplitProposalCard: View {
    @Binding var proposal: SplitProposal
    let number: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            cardHeader

            Divider()
                .background(Color.theme.border)

            TextField("Title", text: $proposal.title)
                .textFieldStyle(.roundedBorder)
                .font(.headline)

            TextField("Description", text: $proposal.what, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .font(.callout)
                .lineLimit(2...4)

            estimateRow
        }
        .padding(14)
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }

    private var cardHeader: some View {
        HStack(spacing: 6) {
            Text("Sub-spec \(number)")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.theme.textTertiary)
                .tracking(0.8)
                .textCase(.uppercase)

            Spacer()
        }
    }

    private var estimateRow: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.theme.textTertiary)

            Text("Estimate")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.theme.textTertiary)

            Stepper(
                value: $proposal.estimate,
                in: 1...13,
                step: 1
            ) {
                Text("\(proposal.estimate) pt\(proposal.estimate == 1 ? "" : "s")")
                    .font(.callout.weight(.semibold))
                    .foregroundColor(Color.theme.textPrimary)
                    .monospacedDigit()
            }
        }
    }
}
