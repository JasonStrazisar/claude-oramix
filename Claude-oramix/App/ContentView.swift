import SwiftUI

struct ContentView: View {
    var selectedTab: Int = 0

    @State private var activeTab: Int = 0

    var body: some View {
        TabView(selection: $activeTab) {
            Text("Specautomatix")
                .tabItem {
                    Label("Specautomatix", systemImage: "hammer")
                }
                .tag(0)

            NuitefixPlaceholderView()
                .tabItem {
                    Label("Nuitéfix", systemImage: "pawprint")
                }
                .tag(1)

            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .onAppear {
            activeTab = selectedTab
        }
        .overlay(alignment: .topLeading) {
            // Hidden buttons to capture keyboard shortcuts
            Group {
                Button("") { activeTab = 0 }
                    .keyboardShortcut("1", modifiers: .command)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                Button("") { activeTab = 1 }
                    .keyboardShortcut("2", modifiers: .command)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                Button("") { activeTab = 2 }
                    .keyboardShortcut(",", modifiers: .command)
                    .frame(width: 0, height: 0)
                    .opacity(0)
            }
        }
    }
}
