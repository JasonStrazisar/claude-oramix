# Claude-oramix — Architecture Document

> Le druide qui orchestre tes agents IA.
> Deux potions, une marmite : **Specautomatix** forge les specs, **Nuitéfix** les exécute la nuit.

---

## Vision

Claude-oramix est une app macOS native unique avec deux vues principales :

- **Specautomatix** — Éditeur de specs structurées avec scoring temps réel. Le forgeron qui refuse le travail bâclé.
- **Nuitéfix** — Orchestrateur d'exécution headless. Le petit chien qui part la nuit chercher tes PRs.

Les deux vues partagent le même store de données, la même fenêtre, et se complètent : Specautomatix produit des specs "Agent Ready", Nuitéfix les consomme.

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                        Claude-oramix.app                             │
│                                                                      │
│  ┌─ Navigation ──────────────────────────────────────────────────┐   │
│  │  [🔨 Specautomatix]    [🐕 Nuitéfix]    [⚙️ Settings]       │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌─ Vue Specautomatix ──────────────────────────────────────────┐   │
│  │ ┌──────────┐  ┌─────────────────┐  ┌────────────────┐       │   │
│  │ │ Sidebar  │  │  Spec Editor    │  │  Score Panel   │       │   │
│  │ │          │  │                 │  │                │       │   │
│  │ │ tickets  │  │  structured     │  │  checklist     │       │   │
│  │ │ list     │  │  sections       │  │  quality score │       │   │
│  │ │ + scores │  │  markdown       │  │  suggestions   │       │   │
│  │ │          │  │                 │  │  split propose │       │   │
│  │ ├──────────┤  ├─────────────────┤  │                │       │   │
│  │ │ Filters  │  │  Terminal       │  │                │       │   │
│  │ │ & Search │  │  (PTY)          │  │                │       │   │
│  │ └──────────┘  └─────────────────┘  └────────────────┘       │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌─ Vue Nuitéfix ───────────────────────────────────────────────┐   │
│  │ ┌──────────┐  ┌─────────────────────────────────────┐       │   │
│  │ │ Ready    │  │  Execution Dashboard                │       │   │
│  │ │ Queue    │  │                                     │       │   │
│  │ │          │  │  budget remaining: ████████░░ 72%   │       │   │
│  │ │ ✅ SC-01 │  │  specs in queue:  4                 │       │   │
│  │ │ ✅ SC-05 │  │  estimated cost:  ~35% budget       │       │   │
│  │ │ ✅ SC-02 │  │                                     │       │   │
│  │ │ 🔄 SC-08 │  │  ┌─ Current ──────────────────┐    │       │   │
│  │ │          │  │  │ SC-1234: French locale      │    │       │   │
│  │ ├──────────┤  │  │ Status: implementing...     │    │       │   │
│  │ │ History  │  │  │ Branch: sc-1234/fr-locale   │    │       │   │
│  │ │          │  │  └─────────────────────────────┘    │       │   │
│  │ │ ✓ SC-03 │  │                                     │       │   │
│  │ │ ✗ SC-07 │  │  ┌─ Terminal ──────────────────┐    │       │   │
│  │ │ ✓ SC-09 │  │  │ claude -p "..." --model...  │    │       │   │
│  │ └──────────┘  │  └─────────────────────────────┘    │       │   │
│  │               └─────────────────────────────────────┘       │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌─ Status Bar ─────────────────────────────────────────────────┐   │
│  │  budget: 72% remaining │ 4 specs ready │ ollama: connected   │   │
│  └──────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Modules

### 1. Shared Data Layer (`Models/`)

Le coeur partagé entre Specautomatix et Nuitéfix.

```swift
struct Spec: Codable, Identifiable {
    let id: UUID
    var shortcutId: String?
    var title: String
    var status: SpecStatus
    var sections: SpecSections
    var metadata: SpecMetadata
    var score: SpecScore
    var execution: ExecutionResult?    // rempli par Nuitéfix
    var createdAt: Date
    var updatedAt: Date
}

struct SpecSections: Codable {
    var what: String
    var where_: [FileTarget]
    var acceptance: [AcceptanceCriteria]
    var nonGoals: [String]
    var patterns: [PatternRef]
    var context: String?
    var technicalNotes: String?
}

struct AcceptanceCriteria: Codable, Identifiable {
    let id: UUID
    var given: String
    var when_: String
    var then_: String
    var type: CriteriaType
}

enum CriteriaType: String, Codable, CaseIterable {
    case happyPath = "happy_path"
    case errorCase = "error_case"
    case edgeCase = "edge_case"
}

struct FileTarget: Codable, Identifiable {
    let id: UUID
    var path: String
    var description: String
}

struct PatternRef: Codable, Identifiable {
    let id: UUID
    var name: String
    var reference: String
}

struct SpecMetadata: Codable {
    var estimate: Int?
    var labels: [String]
    var epic: String?
    var dependencies: [String]
    var mergeSafeDeclaration: String?   // HOW this MR stays merge-safe
}

enum SpecStatus: String, Codable, CaseIterable {
    case draft
    case ready           // score ≥ 80
    case queued          // dans la queue Nuitéfix
    case inProgress      // agent en cours
    case done            // PR créée
    case failed          // exécution échouée
    case split           // découpé en sous-specs
}

struct ExecutionResult: Codable {
    var branch: String
    var prURL: String?
    var model: String
    var tokensUsed: Int?
    var duration: TimeInterval
    var status: ExecutionStatus
    var logs: String
    var startedAt: Date
    var completedAt: Date
}

enum ExecutionStatus: String, Codable {
    case success
    case testsFailed
    case error
    case timeout
}
```

### 2. Specautomatix — Scoring (`Specautomatix/Scoring/`)

#### Règles Statiques

```swift
struct StaticScorer {
    func score(_ spec: Spec) -> SpecScore
}

struct SpecScore: Codable {
    var total: Int
    var grade: ScoreGrade
    var checks: [ScoreCheck]
    var suggestions: [String]
    var isAgentReady: Bool
}

enum ScoreGrade: String, Codable { case A, B, C, D, F }

struct ScoreCheck: Codable, Identifiable {
    let id: UUID
    var category: CheckCategory
    var name: String
    var passed: Bool
    var weight: Int
    var message: String
}

enum CheckCategory: String, Codable, CaseIterable {
    case completeness, clarity, testability, scope, safety
}
```

Détail des 11 règles → [SCORING_RULES.md](./SCORING_RULES.md)

#### Ollama (optionnel)

```swift
struct OllamaScorer {
    let endpoint: URL
    let model: String
    func analyzeQuality(_ spec: Spec) async throws -> OllamaAnalysis
    func isAvailable() async -> Bool
}

struct OllamaAnalysis: Codable {
    var ambiguities: [String]
    var missingContext: [String]
    var splitSuggestions: [SplitSuggestion]?
    var overallAssessment: String
}
```

### 3. Specautomatix — Prompt Builder

```swift
struct PromptBuilder {
    static func build(from spec: Spec) -> String {
        """
        ## Task
        \(spec.title)
        
        ## Description
        \(spec.sections.what)
        
        ## Files to modify
        \(spec.sections.where_.map { "- `\($0.path)`: \($0.description)" }.joined(separator: "\n"))
        
        ## Acceptance Criteria
        \(spec.sections.acceptance.map { c in
            "- **[\(c.type.rawValue)]** Given: \(c.given) | When: \(c.when_) | Then: \(c.then_)"
        }.joined(separator: "\n"))
        
        ## Non-Goals (DO NOT)
        \(spec.sections.nonGoals.map { "- \($0)" }.joined(separator: "\n"))
        
        ## Patterns to follow
        \(spec.sections.patterns.map { "- \($0.name): \($0.reference)" }.joined(separator: "\n"))
        
        \(spec.sections.context.map { "## Context\n\($0)" } ?? "")
        \(spec.sections.technicalNotes.map { "## Technical Notes\n\($0)" } ?? "")
        
        ## Instructions
        - Branch: `sc-\(spec.shortcutId ?? spec.id.uuidString)/\(spec.title.slugified)`
        - Implement changes, write tests for each criterion, ensure all pass
        - Commit with descriptive message referencing the spec
        """
    }
}
```

### 4. Nuitéfix — Engine & Budget

```swift
class NuitefixEngine: ObservableObject {
    @Published var queue: [Spec] = []
    @Published var currentExecution: Spec?
    @Published var history: [ExecutionResult] = []
    @Published var budget: BudgetStatus
    
    func loadQueue() { /* specs where status == .ready && score.isAgentReady */ }
    func execute(_ spec: Spec) async throws -> ExecutionResult { /* headless */ }
    func executeNext() async throws { /* next in queue */ }
    func executeAll() async throws { /* sequential */ }
    func stop() { /* cancel current */ }
}

struct BudgetTracker {
    // Parse ~/.config/claude/projects/ JSONL files
    func currentUsage() -> BudgetStatus
}

struct BudgetStatus: Codable {
    var usedToday: TokenUsage
    var usedThisWeek: TokenUsage
    var usedThisMonth: TokenUsage
    var estimatedCapacity: TokenUsage
    var remainingPercent: Double
    var canExecute: Bool
}
```

### 5. Terminal (`Shared/Terminal/`)

```swift
class TerminalManager: ObservableObject {
    @Published var isRunning: Bool = false
    func openInteractiveSession(context: Spec?) async     // Specautomatix
    func runHeadless(prompt: String) async throws -> ClaudeCodeResult  // Nuitéfix
    func send(_ command: String)
}
```

### 6. Store (`Shared/Store/`)

```swift
class SpecStore: ObservableObject {
    @Published var specs: [Spec] = []
    // ~/Library/Application Support/Claude-oramix/specs.json
    func load() / save() / delete() / updateStatus() / updateExecution()
    func export(_ spec: Spec, to format: ExportFormat) -> Data
}
```

---

## Project Structure

```
Claude-oramix/
├── Claude-oramix.xcodeproj
├── Claude-oramix/
│   ├── App/
│   │   ├── ClaudeOramixApp.swift
│   │   ├── AppState.swift
│   │   ├── ContentView.swift
│   │   └── Settings/
│   │
│   ├── Models/                           # PARTAGÉ
│   │   ├── Spec.swift
│   │   ├── SpecScore.swift
│   │   ├── ExecutionResult.swift
│   │   ├── BudgetStatus.swift
│   │   └── MockData.swift
│   │
│   ├── Shared/                           # PARTAGÉ
│   │   ├── Store/
│   │   ├── Terminal/
│   │   └── Services/
│   │
│   ├── Specautomatix/                    # VUE SPEC
│   │   ├── Scoring/
│   │   ├── Services/
│   │   └── Views/
│   │       ├── SpecautomatixView.swift
│   │       ├── Sidebar/
│   │       ├── Editor/
│   │       ├── Score/
│   │       ├── Preview/
│   │       └── Split/
│   │
│   ├── Nuitefix/                         # VUE NIGHTSHIFT
│   │   ├── Services/
│   │   └── Views/
│   │       ├── NuitefixView.swift
│   │       ├── QueueListView.swift
│   │       ├── HistoryListView.swift
│   │       ├── BudgetBarView.swift
│   │       └── CurrentExecutionView.swift
│   │
│   └── Resources/
│
├── Claude-oramixTests/
├── ARCHITECTURE.md
├── SCORING_RULES.md
├── MOCK_DATA.md
└── README.md
```

---

## Keyboard Shortcuts

| Shortcut | Scope | Action |
|----------|-------|--------|
| `⌘1` | Global | Specautomatix |
| `⌘2` | Global | Nuitéfix |
| `⌘,` | Global | Settings |
| `⌘N` | Specautomatix | Nouvelle spec |
| `⌘↑/⌘↓` | Specautomatix | Spec précédente/suivante |
| `⌘P` | Specautomatix | Preview prompt |
| `⌘T` | Specautomatix | Toggle terminal |
| `⌘⇧S` | Specautomatix | Check Ollama |
| `⌘E` | Specautomatix | Export |
| `⌘F` | Specautomatix | Rechercher |
| `⌘R` | Nuitéfix | Run next |
| `⌘⇧R` | Nuitéfix | Run all |
| `⌘.` | Nuitéfix | Stop |
| `⌘B` | Nuitéfix | Refresh budget |

---

## Roadmap

| Phase | Scope | Status |
|-------|-------|--------|
| **1** | Specautomatix Core : éditeur, scoring, sidebar, mock, preview, persistence | ← ON EST LÀ |
| **2** | Specautomatix+ : terminal, Ollama, split auto | |
| **3** | Nuitéfix Core : budget, queue, headless, dashboard | |
| **4** | Shortcut : fetch/update tickets, sync bidirectionnelle | |
| **5** | Nuitéfix+ : batch, PR, scheduling, reporting, notifications | |

---

## Tech Notes

- **Terminal** : SwiftTerm pour le MVP, Ghostty (libghostty) exploré plus tard
- **Ollama** : API REST `http://localhost:11434`, modèles `qwen2.5-coder:3b` / `llama3.2:3b`
- **Persistence** : JSON dans `~/Library/Application Support/Claude-oramix/`, compatible Ralph
- **Claude Code** : interactif via PTY (Specautomatix), headless via `claude -p` (Nuitéfix)