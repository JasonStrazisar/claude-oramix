import SwiftUI

// TODO P1-002: will be replaced by full SpecStore implementation
class SpecStore: ObservableObject {}

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
