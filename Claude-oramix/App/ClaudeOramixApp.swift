import SwiftUI

@main
struct ClaudeOramixApp: App {
    @StateObject private var specStore = SpecStore()

    var body: some Scene {
        WindowGroup("Claude-oramix") {
            ContentView()
                .environmentObject(specStore)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
