import SwiftUI

struct SpecEditorView: View {
    @Binding var spec: Spec
    let onDelete: (UUID) -> Void

    @State private var showDeleteConfirmation = false
    @State private var showTerminal = false
    @State private var terminalInput = ""
    @StateObject private var terminalManager = TerminalManager()

    var body: some View {
        VStack(spacing: 0) {
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

            if showTerminal {
                Divider()
                TerminalView(manager: terminalManager)
                    .frame(minHeight: 180, idealHeight: 220)
                terminalInputBar
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    openInteractiveSession(context: spec)
                } label: {
                    Label("Open in Claude", systemImage: "arrow.up.right.circle")
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                .help("Open in Claude (⌘⇧C)")
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showTerminal.toggle()
                } label: {
                    Label("Toggle Terminal", systemImage: "terminal")
                }
                .keyboardShortcut("t", modifiers: .command)
                .help("Toggle Terminal (⌘T)")
            }
        }
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

    // MARK: - Claude Integration

    func buildClaudeCommand(for spec: Spec) -> [String] {
        let prompt = PromptBuilder.build(from: spec)
        return ["claude", prompt]
    }

    func openInteractiveSession(context spec: Spec) {
        if !showTerminal {
            showTerminal = true
        }
        let prompt = PromptBuilder.build(from: spec)
        // Temp file avoids all shell escaping issues with multi-line/special-char content
        let tmpPath = (NSTemporaryDirectory() as NSString)
            .appendingPathComponent("claude-oramix-context.md")
        try? prompt.write(toFile: tmpPath, atomically: true, encoding: .utf8)
        // Interactive login shell (-il) needed to load .zshrc/.bashrc AND .zprofile
        // so that PATH modifications (nvm, homebrew, etc.) are available
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        terminalManager.spawn(command: "\(shell) -il -c 'cat \"\(tmpPath)\" && claude'")
    }

    // MARK: - Terminal input

    @ViewBuilder
    private var terminalInputBar: some View {
        HStack(spacing: 8) {
            Text("❯")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.green)

            TextField("", text: $terminalInput)
                .font(.system(size: 12, design: .monospaced))
                .textFieldStyle(.plain)
                .foregroundColor(.white)
                .onSubmit {
                    terminalManager.send(terminalInput + "\n")
                    terminalInput = ""
                }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: NSColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)))
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
