# Roadmap Phase 1 — Claude-oramix / Specautomatix

**20 issues · 24 SP · 7 vagues · chemin critique = 10 SP**

Généré le 2026-02-28 depuis les issues GitHub label `phase-1`.

---

## Analyse du graphe de dépendances

**Racines (aucune dépendance — démarrent immédiatement) :**
- `P1-001` — Data models *(9 issues en dépendent)*
- `P1-009` — App shell *(3 issues en dépendent)*

**Feuilles (rien n'en dépend) :**
- `P1-018` — Keyboard navigation ← fin de la chaîne principale
- `P1-019` — Nuitéfix placeholder ← branche latérale
- `P1-020` — Settings placeholder ← branche latérale

**Chemin critique :**
```
P1-001 → P1-004 → P1-005 → P1-008 → P1-015 → P1-017 → P1-018
   1   +    1   +    1   +    2   +    2   +    2   +    1   = 10 SP
```

---

## Waves d'exécution

### Wave 1 — Fondations — 2 SP — 2 agents en parallèle

| Issue | #GitHub | SP | Titre |
|-------|---------|-----|-------|
| `P1-001` | #1 | 1 | Data models — Spec, SpecSections, SpecScore |
| `P1-009` | #2 | 1 | App shell — ClaudeOramixApp, ContentView, tab nav |

> `P1-001` débloque 9 issues, `P1-009` en débloque 3. Priorité absolue.

---

### Wave 2 — Explosion maximale — 10 SP — 9 agents en parallèle

| Issue | #GitHub | SP | Dépend de | Titre |
|-------|---------|-----|-----------|-------|
| `P1-002` | #3 | 1 | P1-001 | SpecStore — Persistence JSON et CRUD |
| `P1-003` | #4 | 1 | P1-001 | MockData — 5 specs Dvore |
| `P1-004` | #5 | 1 | P1-001 | StaticScorer struct + completeness C1-C4 |
| `P1-011` | #7 | 1 | P1-001 | Editor — WhatSectionView + WhereSectionView |
| `P1-012` | #8 | 1 | P1-001 | Editor — AcceptanceSectionView (G/W/T builder) |
| `P1-013` | #9 | 2 | P1-001 | Editor — NonGoals + Patterns + Context + Notes + Metadata |
| `P1-016` | #10 | 1 | P1-001 | PromptBuilder + PromptPreviewView |
| `P1-019` | #11 | 1 | P1-009 | Nuitéfix placeholder view *(feuille)* |
| `P1-020` | #12 | 1 | P1-009 | Settings placeholder view *(feuille)* |

> `P1-019` et `P1-020` sont des feuilles : aucun bloquage si elles sont reportées.

---

### Wave 3 — Scorer checks + assemblages UI — 5 SP — 5 agents en parallèle

| Issue | #GitHub | SP | Dépend de | Titre |
|-------|---------|-----|-----------|-------|
| `P1-005` | #13 | 1 | P1-004 | StaticScorer — Clarity CL1-CL2 + cascade |
| `P1-006` | #14 | 1 | P1-004 | StaticScorer — Testability T1-T2 + cascade |
| `P1-007` | #15 | 1 | P1-004 | StaticScorer — Safety S1-S3 + Bonus B1-B3 |
| `P1-010` | #6 | 1 | P1-001, P1-002 | SpecSidebar — liste de specs avec badges de score |
| `P1-014` | #16 | 1 | P1-011, P1-012, P1-013 | SpecEditorView — Assemblage de toutes les sections |

> `P1-005/006/007` doivent toutes finir avant `P1-008`. `P1-013` (2 SP) est le plus long de Wave 2 et conditionne `P1-014`.

---

### Wave 4 — Agrégation du scorer — 2 SP — 1 agent

| Issue | #GitHub | SP | Dépend de | Titre |
|-------|---------|-----|-----------|-------|
| `P1-008` | #17 | 2 | P1-005, P1-006, P1-007 | StaticScorer — Agrégation score total, grade, suggestions |

> Goulot d'étranglement : attend que les 3 scorers de Wave 3 soient terminés.

---

### Wave 5 — Panel de score — 2 SP — 1 agent

| Issue | #GitHub | SP | Dépend de | Titre |
|-------|---------|-----|-----------|-------|
| `P1-015` | #18 | 2 | P1-001, P1-008 | ScorePanelView — Checklist + suggestions temps réel |

---

### Wave 6 — Assemblage final — 2 SP — 1 agent

| Issue | #GitHub | SP | Dépend de | Titre |
|-------|---------|-----|-----------|-------|
| `P1-017` | #19 | 2 | P1-009, P1-002, P1-003, P1-010, P1-014, P1-015, P1-016 | SpecautomatixView — Layout 3 panels + wiring complet |

> Attend 7 prérequis (toutes les briques UI + données + scorer).

---

### Wave 7 — Polish final — 1 SP — 1 agent

| Issue | #GitHub | SP | Dépend de | Titre |
|-------|---------|-----|-----------|-------|
| `P1-018` | #20 | 1 | P1-017 | Keyboard navigation — ⌘↑/⌘↓, ⌘N, ⌘F |

---

## Résumé

```
Wave 1 ████░░░░░░░░░░░░  2 SP  — 2 agents   (fondations)
Wave 2 ████████████████ 10 SP  — 9 agents   (explosion max)
Wave 3 ████████░░░░░░░░  5 SP  — 5 agents   (checks + assemblages)
Wave 4 ████░░░░░░░░░░░░  2 SP  — 1 agent    (agrégation scorer)
Wave 5 ████░░░░░░░░░░░░  2 SP  — 1 agent    (panel score)
Wave 6 ████░░░░░░░░░░░░  2 SP  — 1 agent    (assemblage final)
Wave 7 ██░░░░░░░░░░░░░░  1 SP  — 1 agent    (keyboard nav)
       ────────────────────────────────────
TOTAL              24 SP  — 7 vagues séquentielles
```

**Ordre de priorité si tu limites les agents :**
1. `P1-001` en premier (débloque 9 issues)
2. `P1-004` dès que possible (chemin critique du scorer)
3. `P1-013` en parallèle (2 SP, conditionne `P1-014`)
4. Après Wave 3 : `P1-008` → `P1-015` → `P1-017` sont linéaires, 1 agent suffit
