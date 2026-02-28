import SwiftUI

struct SpecEditorView: View {
    @Binding var spec: Spec
    let onDelete: (UUID) -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                WhatSectionView(what: $spec.sections.what)
                WhereSectionView(fileTargets: $spec.sections.where_)
                AcceptanceSectionView(criteria: $spec.sections.acceptance)
                NonGoalsSectionView(nonGoals: $spec.sections.nonGoals)
                PatternsSectionView(patterns: $spec.sections.patterns)
                ContextSectionView(context: $spec.sections.context)
                TechnicalNotesSectionView(technicalNotes: $spec.sections.technicalNotes)
                MetadataSectionView(metadata: $spec.metadata)

                deleteButton
            }
            .padding(24)
        }
        .background(Color.theme.background)
        .confirmationDialog(
            "Delete this spec?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { onDelete(spec.id) }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Title
            TextField("Spec title", text: $spec.title)
                .font(.system(size: 22, weight: .bold, design: .default))
                .foregroundColor(Color.theme.textPrimary)
                .textFieldStyle(.plain)

            if let shortcutId = spec.shortcutId {
                Text(shortcutId)
                    .font(.system(size: 11, weight: .regular, design: .monospaced))
                    .foregroundColor(Color.theme.textTertiary)
            }

            // Status segmented picker
            Picker("Status", selection: $spec.status) {
                ForEach(SpecStatus.allCases, id: \.self) { status in
                    Text(statusLabel(status)).tag(status)
                }
            }
            .pickerStyle(.segmented)
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

    @ViewBuilder
    private var deleteButton: some View {
        HStack {
            Spacer()
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete Spec", systemImage: "trash")
                    .font(.callout)
                    .foregroundColor(Color.theme.destructive)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func statusLabel(_ status: SpecStatus) -> String {
        switch status {
        case .draft:      return "Draft"
        case .ready:      return "Ready"
        case .queued:     return "Queued"
        case .inProgress: return "In Progress"
        case .done:       return "Done"
        case .failed:     return "Failed"
        case .split:      return "Split"
        }
    }
}
