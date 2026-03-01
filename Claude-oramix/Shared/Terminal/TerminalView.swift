import SwiftUI
import AppKit

// MARK: - TerminalView

struct TerminalView: NSViewRepresentable {

    @ObservedObject var manager: TerminalManager

    // MARK: - NSViewRepresentable

    func makeNSView(context: Context) -> NSScrollView {
        let textView = makeTextView()
        let scrollView = makeScrollView(containing: textView)
        context.coordinator.textView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView else { return }
        let content = resolvedContent()
        let isPlaceholder = manager.output.isEmpty && !manager.isRunning

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: isPlaceholder
                ? NSColor.gray
                : NSColor(red: 0.2, green: 0.9, blue: 0.4, alpha: 1)
        ]

        textView.string = ""
        let attributed = NSAttributedString(string: content, attributes: attributes)
        textView.textStorage?.setAttributedString(attributed)

        scrollToBottom(textView)
    }

    // MARK: - Coordinator

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator {
        weak var textView: NSTextView?
    }

    // MARK: - Private helpers

    private func resolvedContent() -> String {
        if manager.output.isEmpty && !manager.isRunning {
            return "Terminal prêt…"
        }
        return manager.output
    }

    private func makeTextView() -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textColor = NSColor(red: 0.2, green: 0.9, blue: 0.4, alpha: 1)
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        return textView
    }

    private func makeScrollView(containing textView: NSTextView) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)
        scrollView.drawsBackground = true
        return scrollView
    }

    private func scrollToBottom(_ textView: NSTextView) {
        guard let scrollView = textView.enclosingScrollView else { return }
        let maxY = textView.bounds.maxY
        let visibleHeight = scrollView.contentView.bounds.height
        let scrollPoint = NSPoint(x: 0, y: max(0, maxY - visibleHeight))
        scrollView.contentView.scroll(to: scrollPoint)
        scrollView.reflectScrolledClipView(scrollView.contentView)
    }
}
