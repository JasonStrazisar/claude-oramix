import SwiftUI

@main
struct ClaudeOramixApp: App {
    @StateObject private var projectStore: ProjectStore
    @StateObject private var specStore: SpecStore
    @StateObject private var ollamaMonitor = OllamaMonitor()

    init() {
        let ps = ProjectStore()
        ps.load()
        let activeId = ps.activeProject?.id
        let ss = activeId != nil ? SpecStore(projectId: activeId!) : SpecStore()
        _projectStore = StateObject(wrappedValue: ps)
        _specStore = StateObject(wrappedValue: ss)
    }

    var body: some Scene {
        WindowGroup("Claude-oramix") {
            ContentView()
                .environmentObject(specStore)
                .environmentObject(ollamaMonitor)
                .environmentObject(projectStore)
                .preferredColorScheme(.light)
        }
        .defaultSize(width: 1280, height: 820)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            SettingsPlaceholderView()
                .preferredColorScheme(.light)
        }
    }
}
