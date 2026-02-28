import SwiftUI

struct ContentView: View {
    var selectedTab: Int = 0

    @State private var activeTab: Int = 0

    var body: some View {
        Group {
            switch activeTab {
            case 1:  NuitefixPlaceholderView()
            default: SpecautomatixView()
            }
        }
        .frame(minWidth: 1100, minHeight: 700)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("", selection: $activeTab) {
                    Label("Specautomatix", systemImage: "hammer.fill").tag(0)
                    Label("Nuitéfix", systemImage: "dog.fill").tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 280)
                .labelsHidden()
            }
        }
        .onAppear {
            activeTab = selectedTab
        }
        .overlay(alignment: .topLeading) {
            Group {
                Button("") { activeTab = 0 }
                    .keyboardShortcut("1", modifiers: .command)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                Button("") { activeTab = 1 }
                    .keyboardShortcut("2", modifiers: .command)
                    .frame(width: 0, height: 0)
                    .opacity(0)
            }
        }
    }
}
