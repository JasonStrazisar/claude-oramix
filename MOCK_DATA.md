# Mock Data — Claude-oramix

Données de test pour Specautomatix. 5 specs avec des niveaux de qualité variés,
inspirées du contexte Dvore (restaurant analytics, i18n, Pulse Builder).

---

## mock-001 — Grade A (100/100) · French locale date formatter

```json
{
  "id": "mock-001",
  "shortcutId": "SC-1234",
  "title": "Add French locale to date formatter utility",
  "status": "ready",
  "sections": {
    "what": "Add French (fr-FR) locale support to the existing date formatter utility. Currently the utility only supports en-US. The formatter is used across all dashboard date displays. The French format should use DD/MM/YYYY for dates, HH:mm for times, and French month names (janvier, février, etc.).",
    "where_": [
      { "path": "src/utils/dateFormatter.ts", "description": "Add fr-FR locale config and formatting rules" },
      { "path": "src/utils/__tests__/dateFormatter.test.ts", "description": "Add test cases for fr-FR formatting" },
      { "path": "src/i18n/locales/fr.json", "description": "Add date-related translation keys if not present" }
    ],
    "acceptance": [
      {
        "given": "A date object '2025-03-15T14:30:00Z'",
        "when_": "Formatted with locale 'fr-FR' and format 'date'",
        "then_": "Returns '15/03/2025'",
        "type": "happy_path"
      },
      {
        "given": "A date object '2025-03-15T14:30:00Z'",
        "when_": "Formatted with locale 'fr-FR' and format 'datetime'",
        "then_": "Returns '15 mars 2025 à 14:30'",
        "type": "happy_path"
      },
      {
        "given": "An invalid date string 'not-a-date'",
        "when_": "Passed to the formatter with locale 'fr-FR'",
        "then_": "Returns the fallback string '-' without throwing",
        "type": "error_case"
      },
      {
        "given": "A null or undefined value",
        "when_": "Passed to the formatter with locale 'fr-FR'",
        "then_": "Returns the fallback string '-' without throwing",
        "type": "edge_case"
      }
    ],
    "nonGoals": [
      "Do NOT modify the existing en-US formatting behavior",
      "Do NOT add other locales (de-DE, es-ES, etc.) in this ticket",
      "Do NOT change the formatter API signature — locale is already an optional parameter"
    ],
    "patterns": [
      { "name": "i18n convention", "reference": "See src/i18n/README.md for locale file structure" },
      { "name": "test pattern", "reference": "Follow existing test structure in dateFormatter.test.ts" }
    ],
    "context": "Dvore is expanding to French-speaking restaurant clients. The date formatter is used in Pulse Builder dashboards and all analytics views.",
    "technicalNotes": "The formatter uses date-fns under the hood. date-fns already has fr locale support via 'date-fns/locale/fr' — just need to wire it up."
  },
  "metadata": {
    "estimate": 1,
    "labels": ["i18n", "nightshift"],
    "epic": "Internationalization",
    "dependencies": []
  }
}
```

**Specautomatix verdict :** ✅ Grade A — Nuitéfix ready.

---

## mock-002 — Grade B (82/100) · CSV export encoding fix

```json
{
  "id": "mock-002",
  "shortcutId": "SC-1235",
  "title": "Fix CSV export encoding for special characters",
  "status": "draft",
  "sections": {
    "what": "Restaurant names with special characters (accents, umlauts, etc.) are exported as garbled text in CSV downloads. The CSV export needs to use UTF-8 BOM encoding to ensure Excel opens files correctly on Windows.",
    "where_": [
      { "path": "src/services/exportService.ts", "description": "Add UTF-8 BOM header to CSV generation" },
      { "path": "src/services/__tests__/exportService.test.ts", "description": "Add encoding test cases" }
    ],
    "acceptance": [
      {
        "given": "A restaurant named 'Café Müller' in the dataset",
        "when_": "Exported as CSV and opened in Excel on Windows",
        "then_": "The name displays correctly as 'Café Müller'",
        "type": "happy_path"
      },
      {
        "given": "An empty dataset",
        "when_": "CSV export is triggered",
        "then_": "Returns a valid CSV file with headers only",
        "type": "edge_case"
      }
    ],
    "nonGoals": [
      "Do NOT change the CSV column structure",
      "Do NOT modify the PDF export functionality"
    ],
    "patterns": [],
    "context": "Multiple French and German restaurant clients have reported this issue.",
    "technicalNotes": null
  },
  "metadata": {
    "estimate": 1,
    "labels": ["bug", "nightshift"],
    "epic": "Data Export",
    "dependencies": []
  }
}
```

**Specautomatix verdict :** ✅ Grade B — Nuitéfix ready, mais améliorations possibles.
- ❌ Pas de pattern référencé (-5)
- ❌ Pas de notes techniques (-2)
- ❌ Manque un error_case (T1 partiel, -5)
- 💡 "Ajoutez un critère error_case (ex: caractères emoji dans le nom)"
- 💡 "Référencez le pattern d'export existant"

---

## mock-003 — Grade C (45/100) · Dashboard performance

```json
{
  "id": "mock-003",
  "shortcutId": "SC-1236",
  "title": "Improve dashboard loading performance",
  "status": "draft",
  "sections": {
    "what": "The main analytics dashboard takes too long to load. We need to improve performance.",
    "where_": [
      { "path": "src/pages/Dashboard.tsx", "description": "Optimize rendering" }
    ],
    "acceptance": [
      {
        "given": "A user opens the main dashboard",
        "when_": "The page loads",
        "then_": "It should be faster than before",
        "type": "happy_path"
      }
    ],
    "nonGoals": [],
    "patterns": [],
    "context": null,
    "technicalNotes": null
  },
  "metadata": {
    "estimate": 3,
    "labels": ["performance", "nightshift"],
    "epic": "Performance",
    "dependencies": []
  }
}
```

**Specautomatix verdict :** ❌ Grade C — Pas prêt pour Nuitéfix.
- ❌ C1 : "What" trop vague, contient "improve" sans métrique
- ❌ C3 : 1 seul critère (minimum 2)
- ❌ CL1 : mots vagues détectés ("improve", "too long")
- ❌ T1 : pas d'error_case/edge_case
- ❌ T2 : "faster than before" non mesurable
- ❌ S1 : pas de non-goals
- 💡 "Précisez une métrique : 'Time to interactive < 2s' ou 'LCP < 1.5s'"
- 💡 "Listez plus de fichiers — un seul fichier pour un ticket performance est suspect"
- 💡 "Estimate de 3 → envisagez un split (profiling vs optimization)"

---

## mock-004 — Grade F (0/100) · Vague feature request

```json
{
  "id": "mock-004",
  "shortcutId": "SC-1237",
  "title": "Add new chart type",
  "status": "draft",
  "sections": {
    "what": "We need a new chart type in Pulse Builder.",
    "where_": [],
    "acceptance": [],
    "nonGoals": [],
    "patterns": [],
    "context": null,
    "technicalNotes": null
  },
  "metadata": {
    "estimate": 5,
    "labels": ["feature"],
    "epic": "Pulse Builder",
    "dependencies": []
  }
}
```

**Specautomatix verdict :** ❌ Grade F — Tout est à faire.
- ❌ Tout est vide ou insuffisant
- ⚠️ Cascade : clarity + testability = N/A
- 💡 "Quel type de chart ? Bar, line, pie, heatmap ?"
- 💡 "Estimate de 5 → obligatoirement un split"
- 💡 "Cette spec nécessite un travail de product design avant spécification technique"

---

## mock-005 — Grade B (87/100) · Tooltip on truncated names

```json
{
  "id": "mock-005",
  "shortcutId": "SC-1238",
  "title": "Add tooltip to truncated restaurant names in table",
  "status": "draft",
  "sections": {
    "what": "In the restaurant list table, long restaurant names are truncated with CSS text-overflow: ellipsis. Users cannot see the full name. Add a tooltip (title attribute or custom tooltip component) that shows the full name on hover.",
    "where_": [
      { "path": "src/components/RestaurantTable/RestaurantNameCell.tsx", "description": "Add tooltip wrapper around the name text" },
      { "path": "src/components/RestaurantTable/__tests__/RestaurantNameCell.test.tsx", "description": "Add test for tooltip presence on long names" }
    ],
    "acceptance": [
      {
        "given": "A restaurant with name 'La Grande Brasserie du Vieux Port de Marseille' (> 40 chars)",
        "when_": "Hovering over the truncated name in the table",
        "then_": "A tooltip displays the full restaurant name",
        "type": "happy_path"
      },
      {
        "given": "A restaurant with name 'Chez Jo' (< 40 chars, not truncated)",
        "when_": "Hovering over the name in the table",
        "then_": "No tooltip is shown (name is fully visible)",
        "type": "edge_case"
      },
      {
        "given": "A restaurant with an empty name (edge case from bad data)",
        "when_": "Rendered in the table",
        "then_": "Displays '-' as fallback, no tooltip",
        "type": "error_case"
      }
    ],
    "nonGoals": [
      "Do NOT change the table column widths",
      "Do NOT add tooltips to other columns"
    ],
    "patterns": [
      { "name": "Tooltip component", "reference": "Use existing Tooltip from src/components/ui/Tooltip.tsx" }
    ],
    "context": "Requested by support team — restaurant clients with long names can't verify their data.",
    "technicalNotes": "The table uses TanStack Table v8. The name cell is a custom renderer."
  },
  "metadata": {
    "estimate": 1,
    "labels": ["ux", "nightshift"],
    "epic": "Restaurant Management",
    "dependencies": []
  }
}
```

**Specautomatix verdict :** ✅ Grade B — Nuitéfix ready.
- 💡 "Ajoutez un critère d'accessibilité (screen reader announcement)"
- Tout le reste est solide.