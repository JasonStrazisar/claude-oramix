import SwiftUI

struct ConversationalSpecView: View {
    @EnvironmentObject private var projectStore: ProjectStore
    @StateObject private var terminalManager = TerminalManager()
    @StateObject private var watcher = TemporarySpecFileWatcher()
    @Environment(\.dismiss) private var dismiss

    @State private var feedbackText: String = ""

    var body: some View {
        Group {
            if let project = projectStore.activeProject {
                activeProjectView(project: project)
            } else {
                noActiveProjectView
            }
        }
        .frame(minWidth: 800, minHeight: 500)
    }

    // MARK: - Active project layout

    @ViewBuilder
    private func activeProjectView(project: Project) -> some View {
        HSplitView {
            TerminalView(manager: terminalManager)
                .frame(minWidth: 400)

            previewPane
                .frame(minWidth: 300)
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Fermer") { dismiss() }
                    .keyboardShortcut("w", modifiers: .command)
            }
        }
        .onAppear {
            spawnClaudeSession(for: project)
        }
        .onChange(of: terminalManager.output) { _, newOutput in
            watcher.parseTerminalOutput(newOutput)
        }
    }

    // MARK: - Preview pane

    @ViewBuilder
    private var previewPane: some View {
        VStack(spacing: 0) {
            if let sections = watcher.parsedSections {
                let spec = makeSpec(from: sections)
                let score = StaticScorer().score(spec)
                let html = MarkdownRenderer.renderHTML(sections: sections, score: score)
                WebViewRepresentable(htmlContent: html)
            } else {
                ZStack {
                    Color(nsColor: NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1))
                    Text("Preview loading...")
                        .foregroundColor(.secondary)
                        .font(.callout)
                }
            }

            Divider()

            feedbackBar
        }
    }

    // MARK: - Feedback bar

    @ViewBuilder
    private var feedbackBar: some View {
        HStack(spacing: 8) {
            TextField("Message de feedback...", text: $feedbackText)
                .textFieldStyle(.roundedBorder)
                .onSubmit { submitFeedback() }

            Button("Envoyer") { submitFeedback() }
                .disabled(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(8)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - No active project

    @ViewBuilder
    private var noActiveProjectView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 36))
                .foregroundColor(.secondary)

            Text("Aucun projet actif")
                .font(.system(.title3, design: .default).weight(.semibold))
                .foregroundColor(.primary)

            Text("Sélectionnez un projet dans la barre d'outils avant d'ouvrir une session conversationnelle.")
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)

            Button("Fermer") { dismiss() }
                .keyboardShortcut("w", modifiers: .command)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Spawn

    private func spawnClaudeSession(for project: Project) {
        let tmpPath = (NSTemporaryDirectory() as NSString)
            .appendingPathComponent("claude-oramix-conversational-context.md")
        let context = PromptBuilder.buildConversationalContext(
            tempFilePath: watcher.filePath,
            projectPath: project.path
        )
        try? context.write(toFile: tmpPath, atomically: true, encoding: .utf8)
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        terminalManager.spawn(
            command: "cd \"\(project.path)\" && \(shell) -il -c 'cat \"\(tmpPath)\" && claude'"
        )
    }

    // MARK: - Helpers

    private func submitFeedback() {
        let trimmed = feedbackText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        terminalManager.send(trimmed + "\n")
        feedbackText = ""
    }

    private func makeSpec(from sections: SpecSections) -> Spec {
        var spec = Spec(title: "")
        spec.sections = sections
        return spec
    }
}
