# Claude-oramix

> Le druide qui orchestre tes agents IA.

Claude-oramix est une app macOS native qui regroupe deux outils pour automatiser ton backlog avec Claude Code :

- **Specautomatix** — Le forgeron qui forge et juge tes specs. Un éditeur structuré avec scoring temps réel qui garantit que chaque ticket est suffisamment bien spécifié pour être exécuté par un agent IA en autonome.

- **Nuitéfix** — Le petit chien fidèle qui part la nuit et te ramène des PRs au matin. L'orchestrateur qui lance Claude Code en headless sur les specs validées par Specautomatix, en respectant ton budget.

## Philosophie

```
                    Claude-oramix
                    ┌─────────────────────────┐
                    │                         │
          ┌────────┴────────┐    ┌────────────┴───────────┐
          │  Specautomatix  │    │       Nuitéfix         │
          │                 │    │                         │
          │  Forge la spec  │───▶│  Exécute la nuit       │
          │  Juge la qualité│    │  Ramène les PRs        │
          │  Score A → Ready│    │  Respecte le budget    │
          └─────────────────┘    └────────────────────────┘
```

L'automatisation de tickets par des agents IA dépend à 90% de la qualité de la spec. Un agent avec une bonne spec et Sonnet surpasse un agent avec une mauvaise spec et Opus. Claude-oramix fait de la qualité de la spec le point de contrôle principal.

## Features

### Specautomatix (vue Spec)

- **Éditeur structuré** — Sections guidées : Quoi, Où, Critères (Given/When/Then), Non-Goals, Patterns
- **Scoring temps réel** — Checklist de 11 règles statiques avec score 0-100 et grade A→F
- **Ollama optionnel** — Analyse sémantique locale pour détecter ambiguïtés et proposer des splits
- **Preview du prompt** — Vois exactement ce que Claude Code recevra
- **Terminal intégré** — Lance Claude Code directement depuis l'app pour affiner une spec
- **Navigation rapide** — ⌘↑/⌘↓ entre specs, sidebar triée par readiness
- **Proposition de split** — Détecte les specs trop grosses et propose un découpage
- **Export** — JSON (compatible Ralph), Markdown, prompt Claude Code

### Nuitéfix (vue Nightshift)

- **Sélection intelligente** — Pioche les specs "Agent Ready" (score ≥ 80) dans le backlog
- **Budget-aware** — Parse les données locales Claude Code (ccusage) pour optimiser la consommation
- **Exécution headless** — Lance Claude Code en mode `--dangerously-skip-permissions` sur des branches isolées
- **Toujours Sonnet** — Pas de choix de modèle, c'est la qualité de la spec qui fait le travail
- **Reporting** — Résumé des PRs créées, tickets mis à jour, budget consommé

## Stack

- Swift / SwiftUI (macOS 14+)
- SwiftTerm (terminal intégré)
- Ollama API locale (optionnel, pour Specautomatix)
- Shortcut API (issue tracker)
- Claude Code CLI (exécution headless)
- Persistence JSON locale

## Architecture

Voir [ARCHITECTURE.md](./ARCHITECTURE.md) pour le design complet.

## Roadmap

| Phase | Scope |
|-------|-------|
| **1 — Specautomatix Core** | Éditeur, scoring statique, sidebar, mock data, preview, persistence |
| **2 — Specautomatix+** | Terminal PTY intégré, scoring Ollama, split auto |
| **3 — Nuitéfix Core** | Exécution headless, budget tracking, branch/PR automation |
| **4 — Shortcut** | API Shortcut bidirectionnelle, sync specs ↔ tickets |
| **5 — Nuitéfix+** | Batch execution, scheduling optionnel, reporting avancé |

## Naming

| Nom | Rôle | Référence |
|-----|------|-----------|
| **Claude-oramix** | L'app, le druide qui orchestre | Claude + Panoramix |
| **Specautomatix** | Vue spec, le forgeron exigeant | Spec + Cétautomatix |
| **Nuitéfix** | Vue nightshift, le chien fidèle | Nuit + Idéfix |

## License

MIT