import SwiftUI

@main
struct ClaudeOramixApp: App {
    @StateObject private var specStore = SpecStore()
    @StateObject private var ollamaMonitor = OllamaMonitor()

    var body: some Scene {
        WindowGroup("Claude-oramix") {
            ContentView()
                .environmentObject(specStore)
                .environmentObject(ollamaMonitor)
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
