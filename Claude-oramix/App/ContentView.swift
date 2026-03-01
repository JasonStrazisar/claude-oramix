import SwiftUI

struct ContentView: View {
    @State private var activeAgent: Agent = .specautomatix

    var body: some View {
        Group {
            switch activeAgent {
            case .specautomatix: SpecautomatixView(activeAgent: $activeAgent)
            case .nuitefix:      NuitefixView(activeAgent: $activeAgent)
            }
        }
        .frame(minWidth: 1100, minHeight: 700)
        .overlay(alignment: .topLeading) {
            Group {
                Button("") { activeAgent = .specautomatix }
                    .keyboardShortcut("1", modifiers: .command)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                Button("") { activeAgent = .nuitefix }
                    .keyboardShortcut("2", modifiers: .command)
                    .frame(width: 0, height: 0)
                    .opacity(0)
            }
        }
    }
}
