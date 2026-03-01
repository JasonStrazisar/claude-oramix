import SwiftUI

struct ConversationalSpecView: View {
    @EnvironmentObject private var projectStore: ProjectStore
    @StateObject private var terminalManager = TerminalManager()
    @Environment(\.dismiss) private var dismiss

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
    }

    // MARK: - Preview pane placeholder

    @ViewBuilder
    private var previewPane: some View {
        ZStack {
            Color(nsColor: NSColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1))
            Text("Preview loading...")
                .foregroundColor(.secondary)
                .font(.callout)
        }
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
            tempFilePath: tmpPath,
            projectPath: project.path
        )
        try? context.write(toFile: tmpPath, atomically: true, encoding: .utf8)
        let shell = ProcessInfo.processInfo.environment["SHELL"] ?? "/bin/zsh"
        terminalManager.spawn(
            command: "cd \"\(project.path)\" && \(shell) -il -c 'cat \"\(tmpPath)\" && claude'"
        )
    }
}
