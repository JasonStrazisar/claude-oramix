import SwiftUI

// MARK: - ProjectPickerView

struct ProjectPickerView: View {

    // MARK: - Environment

    @EnvironmentObject private var projectStore: ProjectStore

    // MARK: - Callbacks

    var onProjectSelected: (Project) -> Void

    // MARK: - State

    @State private var showCreateSheet: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var editingProject: Project? = nil
    @State private var projectToDelete: Project? = nil

    // MARK: - Body

    var body: some View {
        Menu {
            projectList
            Divider()
            manageSection
        } label: {
            menuLabel
        }
        .menuStyle(.borderlessButton)
        .fixedSize()
        .sheet(isPresented: $showCreateSheet) {
            ProjectFormSheet(mode: .create) { project in
                projectStore.add(project)
                onProjectSelected(project)
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let project = editingProject {
                ProjectFormSheet(mode: .edit(project)) { updated in
                    projectStore.update(updated)
                }
            }
        }
        .confirmationDialog(
            deleteConfirmTitle,
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Supprimer", role: .destructive) {
                if let project = projectToDelete {
                    handleDelete(project)
                }
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette action est irréversible.")
        }
    }

    // MARK: - Menu label

    private var menuLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "folder.fill")
                .font(.caption)
                .foregroundStyle(Color.theme.accent)
            Text(projectStore.activeProject?.name ?? "Aucun projet")
                .font(.callout.weight(.medium))
                .foregroundStyle(Color.theme.textPrimary)
            Image(systemName: "chevron.down")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.theme.textTertiary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.theme.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.theme.border, lineWidth: 1)
        )
    }

    // MARK: - Project list section

    @ViewBuilder
    private var projectList: some View {
        if projectStore.projects.isEmpty {
            Text("Aucun projet")
                .foregroundStyle(.secondary)
        } else {
            ForEach(projectStore.projects) { project in
                Button {
                    activateProject(project)
                } label: {
                    HStack {
                        Text(project.name)
                        Spacer()
                        if project.id == projectStore.activeProjectId {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }

    // MARK: - Manage section

    @ViewBuilder
    private var manageSection: some View {
        Button {
            showCreateSheet = true
        } label: {
            Label("Nouveau projet…", systemImage: "plus")
        }

        if let active = projectStore.activeProject {
            Button {
                editingProject = active
                showEditSheet = true
            } label: {
                Label("Modifier \"\(active.name)\"…", systemImage: "pencil")
            }

            Button(role: .destructive) {
                projectToDelete = active
                showDeleteConfirm = true
            } label: {
                Label("Supprimer \"\(active.name)\"", systemImage: "trash")
            }
            .disabled(projectStore.projects.count <= 1)
        }
    }

    // MARK: - Helpers

    private var deleteConfirmTitle: String {
        guard let project = projectToDelete else { return "Supprimer le projet" }
        return "Supprimer \"\(project.name)\" ?"
    }

    private func activateProject(_ project: Project) {
        guard project.id != projectStore.activeProjectId else { return }
        projectStore.activeProjectId = project.id
        onProjectSelected(project)
    }

    private func handleDelete(_ project: Project) {
        guard projectStore.projects.count > 1 else { return }
        projectStore.delete(project.id)
        if projectStore.activeProjectId == project.id || projectStore.activeProjectId == nil {
            if let first = projectStore.projects.first {
                projectStore.activeProjectId = first.id
                onProjectSelected(first)
            }
        }
    }
}

// MARK: - ProjectFormSheet

private struct ProjectFormSheet: View {

    // MARK: - Mode

    enum Mode {
        case create
        case edit(Project)
    }

    // MARK: - Input

    let mode: Mode
    let onSave: (Project) -> Void

    // MARK: - State

    @State private var name: String
    @State private var path: String
    @State private var nameError: String? = nil

    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    init(mode: Mode, onSave: @escaping (Project) -> Void) {
        self.mode = mode
        self.onSave = onSave
        switch mode {
        case .create:
            _name = State(initialValue: "")
            _path = State(initialValue: "")
        case .edit(let project):
            _name = State(initialValue: project.name)
            _path = State(initialValue: project.path)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            header
            form
            footer
        }
        .padding(28)
        .frame(width: 440)
    }

    // MARK: - Subviews

    private var header: some View {
        Text(title)
            .font(.title3.weight(.semibold))
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Nom du projet")
                    .font(.headline)
                TextField("ex. Mon Projet", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: name) {
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
                    TextField("/chemin/vers/repo", text: $path)
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
            Button("Annuler") {
                dismiss()
            }
            .keyboardShortcut(.cancelAction)
            Spacer()
            Button(saveButtonLabel) {
                save()
            }
            .keyboardShortcut(.defaultAction)
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: - Helpers

    private var title: String {
        switch mode {
        case .create: return "Nouveau projet"
        case .edit:   return "Modifier le projet"
        }
    }

    private var saveButtonLabel: String {
        switch mode {
        case .create: return "Créer"
        case .edit:   return "Enregistrer"
        }
    }

    private func selectDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Sélectionner"
        if panel.runModal() == .OK, let url = panel.url {
            path = url.path
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            nameError = "Le nom du projet est requis."
            return
        }
        let project: Project
        switch mode {
        case .create:
            project = Project(name: trimmed, path: path)
        case .edit(let existing):
            project = Project(id: existing.id, name: trimmed, path: path, issueTracker: existing.issueTracker)
        }
        onSave(project)
        dismiss()
    }
}
