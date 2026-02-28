import SwiftUI

struct SpecEditorView: View {
    @Binding var spec: Spec
    let onDelete: (UUID) -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Header

                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Title", text: $spec.title)
                            .font(.title2)
                            .textFieldStyle(.plain)

                        if let shortcutId = spec.shortcutId {
                            Text(shortcutId)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Picker("Status", selection: $spec.status) {
                            ForEach(SpecStatus.allCases, id: \.self) { status in
                                Text(status.rawValue).tag(status)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                // MARK: - Sections

                WhatSectionView(what: $spec.sections.what)

                WhereSectionView(fileTargets: $spec.sections.where_)

                AcceptanceSectionView(criteria: $spec.sections.acceptance)

                NonGoalsSectionView(nonGoals: $spec.sections.nonGoals)

                PatternsSectionView(patterns: $spec.sections.patterns)

                ContextSectionView(context: $spec.sections.context)

                TechnicalNotesSectionView(technicalNotes: $spec.sections.technicalNotes)

                MetadataSectionView(metadata: $spec.metadata)

                // MARK: - Delete

                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Text("Delete Spec")
                    }
                    Spacer()
                }
                .padding(.top, 8)
            }
            .padding()
        }
        .confirmationDialog(
            "Delete this spec?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete(spec.id)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
