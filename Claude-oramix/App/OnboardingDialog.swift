import SwiftUI

struct OnboardingDialog: View {

    // MARK: - Environment

    @EnvironmentObject private var projectStore: ProjectStore

    // MARK: - Binding

    @Binding var isPresented: Bool

    // MARK: - State

    @State private var projectName: String = ""
    @State private var repoPath: String = ""
    @State private var nameError: String? = nil

    // MARK: - Private

    private var canCreate: Bool {
        !projectName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            form
            footer
        }
        .padding(28)
        .frame(width: 480)
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bienvenue dans Claude-oramix")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Créez votre premier projet pour commencer.")
                .foregroundStyle(.secondary)
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nom du projet")
                    .font(.headline)
                TextField("ex. Mon Projet", text: $projectName)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: projectName) { _, _ in
                        if nameError != nil { nameError = nil }
                    }
                if let error = nameError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Chemin du dépôt local")
                    .font(.headline)
                HStack {
                    TextField("/chemin/vers/repo", text: $repoPath)
                        .textFieldStyle(.roundedBorder)
                    Button("Parcourir…") {
                        selectDirectory()
                    }
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button("Créer le projet") {
                createProject()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!canCreate)
        }
    }

    // MARK: - Actions

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Sélectionner"
        if panel.runModal() == .OK, let url = panel.url {
            repoPath = url.path
        }
    }

    private func createProject() {
        let trimmedName = projectName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else {
            nameError = "Le nom du projet est requis."
            return
        }

        let project = Project(name: trimmedName, path: repoPath)
        projectStore.add(project)
        migrateGlobalSpecs(to: project)
        isPresented = false
    }

    // MARK: - Migration

    private func migrateGlobalSpecs(to project: Project) {
        let fm = FileManager.default
        let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Claude-oramix")
        let globalSpecsURL = appSupport.appendingPathComponent("specs.json")

        guard fm.fileExists(atPath: globalSpecsURL.path) else { return }

        let projectDir = appSupport
            .appendingPathComponent("projects")
            .appendingPathComponent(project.id.uuidString)
        let destinationURL = projectDir.appendingPathComponent("specs.json")

        try? fm.createDirectory(at: projectDir, withIntermediateDirectories: true)
        try? fm.moveItem(at: globalSpecsURL, to: destinationURL)
    }
}
