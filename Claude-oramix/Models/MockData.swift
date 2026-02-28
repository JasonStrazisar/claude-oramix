import Foundation

// MARK: - Spec memberwise init for MockData

extension Spec {
    init(
        id: UUID,
        shortcutId: String?,
        title: String,
        status: SpecStatus,
        sections: SpecSections,
        metadata: SpecMetadata,
        score: SpecScore,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.shortcutId = shortcutId
        self.title = title
        self.status = status
        self.sections = sections
        self.metadata = metadata
        self.score = score
        self.execution = nil
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - MockData

struct MockData {
    static let specs: [Spec] = [
        mock001(),
        mock002(),
        mock003(),
        mock004(),
        mock005()
    ]
}

// MARK: - Private mock builders

private func mock001() -> Spec {
    Spec(
        id: UUID(uuidString: "00000001-0000-0000-0000-000000000001")!,
        shortcutId: "SC-1234",
        title: "Add French locale to date formatter utility",
        status: .ready,
        sections: SpecSections(
            what: "Add French (fr-FR) locale support to the existing date formatter utility. Currently the utility only supports en-US. The formatter is used across all dashboard date displays. The French format should use DD/MM/YYYY for dates, HH:mm for times, and French month names (janvier, février, etc.).",
            where_: [
                FileTarget(
                    id: UUID(uuidString: "00000001-0000-0000-0001-000000000001")!,
                    path: "src/utils/dateFormatter.ts",
                    description: "Add fr-FR locale config and formatting rules"
                ),
                FileTarget(
                    id: UUID(uuidString: "00000001-0000-0000-0001-000000000002")!,
                    path: "src/utils/__tests__/dateFormatter.test.ts",
                    description: "Add test cases for fr-FR formatting"
                ),
                FileTarget(
                    id: UUID(uuidString: "00000001-0000-0000-0001-000000000003")!,
                    path: "src/i18n/locales/fr.json",
                    description: "Add date-related translation keys if not present"
                )
            ],
            acceptance: [
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000001-0000-0000-0002-000000000001")!,
                    given: "A date object '2025-03-15T14:30:00Z'",
                    when_: "Formatted with locale 'fr-FR' and format 'date'",
                    then_: "Returns '15/03/2025'",
                    type: .happyPath
                ),
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000001-0000-0000-0002-000000000002")!,
                    given: "A date object '2025-03-15T14:30:00Z'",
                    when_: "Formatted with locale 'fr-FR' and format 'datetime'",
                    then_: "Returns '15 mars 2025 à 14:30'",
                    type: .happyPath
                ),
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000001-0000-0000-0002-000000000003")!,
                    given: "An invalid date string 'not-a-date'",
                    when_: "Passed to the formatter with locale 'fr-FR'",
                    then_: "Returns the fallback string '-' without throwing",
                    type: .errorCase
                ),
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000001-0000-0000-0002-000000000004")!,
                    given: "A null or undefined value",
                    when_: "Passed to the formatter with locale 'fr-FR'",
                    then_: "Returns the fallback string '-' without throwing",
                    type: .edgeCase
                )
            ],
            nonGoals: [
                "Do NOT modify the existing en-US formatting behavior",
                "Do NOT add other locales (de-DE, es-ES, etc.) in this ticket",
                "Do NOT change the formatter API signature — locale is already an optional parameter"
            ],
            patterns: [
                PatternRef(
                    id: UUID(uuidString: "00000001-0000-0000-0003-000000000001")!,
                    name: "i18n convention",
                    reference: "See src/i18n/README.md for locale file structure"
                ),
                PatternRef(
                    id: UUID(uuidString: "00000001-0000-0000-0003-000000000002")!,
                    name: "test pattern",
                    reference: "Follow existing test structure in dateFormatter.test.ts"
                )
            ],
            context: "Dvore is expanding to French-speaking restaurant clients. The date formatter is used in Pulse Builder dashboards and all analytics views.",
            technicalNotes: "The formatter uses date-fns under the hood. date-fns already has fr locale support via 'date-fns/locale/fr' — just need to wire it up."
        ),
        metadata: SpecMetadata(
            estimate: 1,
            labels: ["i18n", "nightshift"],
            epic: "Internationalization",
            dependencies: []
        ),
        score: .empty,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}

private func mock002() -> Spec {
    Spec(
        id: UUID(uuidString: "00000002-0000-0000-0000-000000000002")!,
        shortcutId: "SC-1235",
        title: "Fix CSV export encoding for special characters",
        status: .draft,
        sections: SpecSections(
            what: "Restaurant names with special characters (accents, umlauts, etc.) are exported as garbled text in CSV downloads. The CSV export needs to use UTF-8 BOM encoding to ensure Excel opens files correctly on Windows.",
            where_: [
                FileTarget(
                    id: UUID(uuidString: "00000002-0000-0000-0001-000000000001")!,
                    path: "src/services/exportService.ts",
                    description: "Add UTF-8 BOM header to CSV generation"
                ),
                FileTarget(
                    id: UUID(uuidString: "00000002-0000-0000-0001-000000000002")!,
                    path: "src/services/__tests__/exportService.test.ts",
                    description: "Add encoding test cases"
                )
            ],
            acceptance: [
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000002-0000-0000-0002-000000000001")!,
                    given: "A restaurant named 'Café Müller' in the dataset",
                    when_: "Exported as CSV and opened in Excel on Windows",
                    then_: "The name displays correctly as 'Café Müller'",
                    type: .happyPath
                ),
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000002-0000-0000-0002-000000000002")!,
                    given: "An empty dataset",
                    when_: "CSV export is triggered",
                    then_: "Returns a valid CSV file with headers only",
                    type: .edgeCase
                )
            ],
            nonGoals: [
                "Do NOT change the CSV column structure",
                "Do NOT modify the PDF export functionality"
            ],
            patterns: [],
            context: "Multiple French and German restaurant clients have reported this issue.",
            technicalNotes: nil
        ),
        metadata: SpecMetadata(
            estimate: 1,
            labels: ["bug", "nightshift"],
            epic: "Data Export",
            dependencies: []
        ),
        score: .empty,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}

private func mock003() -> Spec {
    Spec(
        id: UUID(uuidString: "00000003-0000-0000-0000-000000000003")!,
        shortcutId: "SC-1236",
        title: "Improve dashboard loading performance",
        status: .draft,
        sections: SpecSections(
            what: "The main analytics dashboard takes too long to load. We need to improve performance.",
            where_: [
                FileTarget(
                    id: UUID(uuidString: "00000003-0000-0000-0001-000000000001")!,
                    path: "src/pages/Dashboard.tsx",
                    description: "Optimize rendering"
                )
            ],
            acceptance: [
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000003-0000-0000-0002-000000000001")!,
                    given: "A user opens the main dashboard",
                    when_: "The page loads",
                    then_: "It should be faster than before",
                    type: .happyPath
                )
            ],
            nonGoals: [],
            patterns: [],
            context: nil,
            technicalNotes: nil
        ),
        metadata: SpecMetadata(
            estimate: 3,
            labels: ["performance", "nightshift"],
            epic: "Performance",
            dependencies: []
        ),
        score: .empty,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}

private func mock004() -> Spec {
    Spec(
        id: UUID(uuidString: "00000004-0000-0000-0000-000000000004")!,
        shortcutId: "SC-1237",
        title: "Add new chart type",
        status: .draft,
        sections: SpecSections(
            what: "We need a new chart type in Pulse Builder.",
            where_: [],
            acceptance: [],
            nonGoals: [],
            patterns: [],
            context: nil,
            technicalNotes: nil
        ),
        metadata: SpecMetadata(
            estimate: 5,
            labels: ["feature"],
            epic: "Pulse Builder",
            dependencies: []
        ),
        score: .empty,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}

private func mock005() -> Spec {
    Spec(
        id: UUID(uuidString: "00000005-0000-0000-0000-000000000005")!,
        shortcutId: "SC-1238",
        title: "Add tooltip to truncated restaurant names in table",
        status: .draft,
        sections: SpecSections(
            what: "In the restaurant list table, long restaurant names are truncated with CSS text-overflow: ellipsis. Users cannot see the full name. Add a tooltip (title attribute or custom tooltip component) that shows the full name on hover.",
            where_: [
                FileTarget(
                    id: UUID(uuidString: "00000005-0000-0000-0001-000000000001")!,
                    path: "src/components/RestaurantTable/RestaurantNameCell.tsx",
                    description: "Add tooltip wrapper around the name text"
                ),
                FileTarget(
                    id: UUID(uuidString: "00000005-0000-0000-0001-000000000002")!,
                    path: "src/components/RestaurantTable/__tests__/RestaurantNameCell.test.tsx",
                    description: "Add test for tooltip presence on long names"
                )
            ],
            acceptance: [
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000005-0000-0000-0002-000000000001")!,
                    given: "A restaurant with name 'La Grande Brasserie du Vieux Port de Marseille' (> 40 chars)",
                    when_: "Hovering over the truncated name in the table",
                    then_: "A tooltip displays the full restaurant name",
                    type: .happyPath
                ),
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000005-0000-0000-0002-000000000002")!,
                    given: "A restaurant with name 'Chez Jo' (< 40 chars, not truncated)",
                    when_: "Hovering over the name in the table",
                    then_: "No tooltip is shown (name is fully visible)",
                    type: .edgeCase
                ),
                AcceptanceCriteria(
                    id: UUID(uuidString: "00000005-0000-0000-0002-000000000003")!,
                    given: "A restaurant with an empty name (edge case from bad data)",
                    when_: "Rendered in the table",
                    then_: "Displays '-' as fallback, no tooltip",
                    type: .errorCase
                )
            ],
            nonGoals: [
                "Do NOT change the table column widths",
                "Do NOT add tooltips to other columns"
            ],
            patterns: [
                PatternRef(
                    id: UUID(uuidString: "00000005-0000-0000-0003-000000000001")!,
                    name: "Tooltip component",
                    reference: "Use existing Tooltip from src/components/ui/Tooltip.tsx"
                )
            ],
            context: "Requested by support team — restaurant clients with long names can't verify their data.",
            technicalNotes: "The table uses TanStack Table v8. The name cell is a custom renderer."
        ),
        metadata: SpecMetadata(
            estimate: 1,
            labels: ["ux", "nightshift"],
            epic: "Restaurant Management",
            dependencies: []
        ),
        score: .empty,
        createdAt: Date(timeIntervalSince1970: 0),
        updatedAt: Date(timeIntervalSince1970: 0)
    )
}
