import SwiftUI

@main
struct ClaudeOramixApp: App {
    @StateObject private var specStore = SpecStore()

    var body: some Scene {
        WindowGroup("Claude-oramix") {
            ContentView()
                .environmentObject(specStore)
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
