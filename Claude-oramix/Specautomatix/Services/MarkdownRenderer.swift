import Foundation

// MARK: - MarkdownRenderer

struct MarkdownRenderer {

    // MARK: - Public API

    static func renderHTML(sections: SpecSections, score: SpecScore?) -> String {
        """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
        \(css)
        </style>
        </head>
        <body>
        \(scoreBadgeHTML(score))
        \(whatHTML(sections.what))
        \(whereHTML(sections.where_))
        \(acceptanceHTML(sections.acceptance))
        \(nonGoalsHTML(sections.nonGoals))
        \(patternsHTML(sections.patterns))
        \(contextHTML(sections.context))
        \(technicalNotesHTML(sections.technicalNotes))
        </body>
        </html>
        """
    }

    // MARK: - Section renderers

    private static func whatHTML(_ what: String) -> String {
        guard !what.isEmpty else { return "" }
        return """
        <section class="section">
        <h2 class="section-title">What</h2>
        <p class="content">\(escapeHTML(what))</p>
        </section>
        """
    }

    private static func whereHTML(_ targets: [FileTarget]) -> String {
        guard !targets.isEmpty else { return "" }
        let rows = targets.map { target in
            """
            <tr>
            <td class="path"><code>\(escapeHTML(target.path))</code></td>
            <td class="desc">\(escapeHTML(target.description))</td>
            </tr>
            """
        }.joined(separator: "\n")
        return """
        <section class="section">
        <h2 class="section-title">Where</h2>
        <table class="table">
        <thead><tr><th>Path</th><th>Description</th></tr></thead>
        <tbody>
        \(rows)
        </tbody>
        </table>
        </section>
        """
    }

    private static func acceptanceHTML(_ criteria: [AcceptanceCriteria]) -> String {
        guard !criteria.isEmpty else { return "" }
        let items = criteria.map { c in
            """
            <div class="criteria-item">
            <span class="criteria-label given">Given</span> \(escapeHTML(c.given))
            <span class="criteria-label when">When</span> \(escapeHTML(c.when_))
            <span class="criteria-label then">Then</span> \(escapeHTML(c.then_))
            </div>
            """
        }.joined(separator: "\n")
        return """
        <section class="section">
        <h2 class="section-title">Acceptance Criteria</h2>
        \(items)
        </section>
        """
    }

    private static func nonGoalsHTML(_ nonGoals: [String]) -> String {
        guard !nonGoals.isEmpty else { return "" }
        let items = nonGoals.map { "<li>\(escapeHTML($0))</li>" }.joined(separator: "\n")
        return """
        <section class="section">
        <h2 class="section-title">Non-Goals</h2>
        <ul class="list">
        \(items)
        </ul>
        </section>
        """
    }

    private static func patternsHTML(_ patterns: [PatternRef]) -> String {
        guard !patterns.isEmpty else { return "" }
        let items = patterns.map { p in
            "<li><strong>\(escapeHTML(p.name))</strong> — \(escapeHTML(p.reference))</li>"
        }.joined(separator: "\n")
        return """
        <section class="section">
        <h2 class="section-title">Patterns</h2>
        <ul class="list">
        \(items)
        </ul>
        </section>
        """
    }

    private static func contextHTML(_ context: String?) -> String {
        guard let context = context, !context.isEmpty else { return "" }
        return """
        <section class="section">
        <h2 class="section-title">Context</h2>
        <p class="content">\(escapeHTML(context))</p>
        </section>
        """
    }

    private static func technicalNotesHTML(_ notes: String?) -> String {
        guard let notes = notes, !notes.isEmpty else { return "" }
        return """
        <section class="section">
        <h2 class="section-title">Technical Notes</h2>
        <p class="content">\(escapeHTML(notes))</p>
        </section>
        """
    }

    private static func scoreBadgeHTML(_ score: SpecScore?) -> String {
        guard let score = score else { return "" }
        let color = gradeColor(score.grade)
        return """
        <div class="score-badge" style="background-color: \(color);">
        <span class="score-grade">\(score.grade.rawValue)</span>
        <span class="score-total">\(score.total)</span>
        </div>
        """
    }

    // MARK: - Helpers

    private static func gradeColor(_ grade: ScoreGrade) -> String {
        switch grade {
        case .A: return "#22c55e"
        case .B: return "#3b82f6"
        case .C: return "#f97316"
        case .D: return "#ef4444"
        case .F: return "#6b7280"
        }
    }

    private static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }

    // MARK: - CSS

    private static let css = """
    *, *::before, *::after { box-sizing: border-box; }
    body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
        font-size: 14px;
        line-height: 1.6;
        color: #1f2937;
        background: #ffffff;
        margin: 0;
        padding: 16px;
    }
    .score-badge {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 6px 14px;
        border-radius: 9999px;
        color: #ffffff;
        font-weight: 700;
        font-size: 15px;
        margin-bottom: 16px;
    }
    .score-grade { font-size: 18px; }
    .score-total { font-size: 14px; opacity: 0.9; }
    .section {
        margin-bottom: 24px;
    }
    .section-title {
        font-size: 13px;
        font-weight: 600;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #6b7280;
        margin: 0 0 8px 0;
        padding-bottom: 4px;
        border-bottom: 1px solid #e5e7eb;
    }
    .content {
        margin: 0;
        white-space: pre-wrap;
        color: #111827;
    }
    .table {
        width: 100%;
        border-collapse: collapse;
        font-size: 13px;
    }
    .table th {
        text-align: left;
        padding: 6px 8px;
        background: #f9fafb;
        color: #6b7280;
        font-weight: 600;
        border: 1px solid #e5e7eb;
    }
    .table td {
        padding: 6px 8px;
        border: 1px solid #e5e7eb;
        vertical-align: top;
    }
    code {
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, monospace;
        font-size: 12px;
        color: #6366f1;
    }
    .criteria-item {
        background: #f9fafb;
        border: 1px solid #e5e7eb;
        border-radius: 6px;
        padding: 10px 12px;
        margin-bottom: 8px;
        line-height: 1.8;
    }
    .criteria-label {
        display: inline-block;
        font-size: 11px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        padding: 1px 6px;
        border-radius: 4px;
        margin-right: 4px;
    }
    .criteria-label.given { background: #dbeafe; color: #1d4ed8; }
    .criteria-label.when  { background: #fef3c7; color: #92400e; }
    .criteria-label.then  { background: #d1fae5; color: #065f46; }
    .list {
        margin: 0;
        padding-left: 20px;
        color: #374151;
    }
    .list li { margin-bottom: 4px; }
    """
}
