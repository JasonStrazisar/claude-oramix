# Scoring Rules — Specautomatix

> Le forgeron ne laisse pas passer le travail bâclé.

## Philosophie

Le scoring ne juge pas la qualité de l'idée — il juge si la spec est suffisamment
structurée pour qu'un agent IA l'exécute sans intervention humaine.

Score ≥ 80 (grade B) = "Agent Ready" → la spec peut passer à Nuitéfix.
Score ≥ 90 (grade A) = "Agent Ready, haute confiance".

---

## Règles Statiques (Niveau 1)

Toujours actives, calcul instantané, pas de dépendance externe.

### Completeness (50 points max)

| ID | Check | Poids | Passe si... |
|----|-------|-------|-------------|
| C1 | `what_present` | 15 | Section "Quoi" non vide ET > 50 caractères |
| C2 | `files_listed` | 15 | Au moins 1 fichier cible identifié |
| C3 | `acceptance_present` | 15 | Au moins 2 critères d'acceptance |
| C4 | `files_have_description` | 5 | Chaque fichier a une description non vide |

### Clarity (20 points max)

| ID | Check | Poids | Passe si... | Dépend de |
|----|-------|-------|-------------|-----------|
| CL1 | `what_no_ambiguity` | 10 | Aucun mot/phrase vague dans "Quoi" | C1 |
| CL2 | `acceptance_gwt_format` | 10 | Tous les critères ont G/W/T non vides | C3 |

**Mots/phrases vagues (CL1) :**
- "should probably", "maybe", "might", "etc.", "and so on"
- "improve", "better", "faster", "optimize" (sans métrique)
- "fix" (sans description du bug)
- "handle properly", "work correctly"
- "as needed", "if necessary", "when appropriate"
- "similar to", "like before" (sans référence explicite)

### Testability (15 points max)

| ID | Check | Poids | Passe si... | Dépend de |
|----|-------|-------|-------------|-----------|
| T1 | `acceptance_types_covered` | 10 | ≥1 happy_path ET ≥1 error/edge_case | C3 |
| T2 | `acceptance_measurable` | 5 | Les "Then" sont concrets, pas vagues | C3 |

**"Then" vagues (T2) :**
- "should work", "displays correctly", "is faster"
- "handles gracefully", "responds appropriately"
- OK : "Returns '15/03/2025'", "Displays error 'Invalid input'", "Response < 200ms"

### Safety (20 points max)

| ID | Check | Poids | Passe si... |
|----|-------|-------|-------------|
| S1 | `non_goals_present` | 10 | Au moins 1 non-goal défini |
| S2 | `scope_reasonable` | 5 | Estimate ≤ 3 points (ou absent) |
| S3 | `merge_safe` | 5 | La spec déclare que le résultat est mergeable seul, sans casser l'app |

**Règle S3 — merge_safe :**
C'est le critère le plus important pour le découpage en issues. Chaque issue
doit produire une MR qui peut être mergée sur main indépendamment, sans :
- Casser la compilation
- Casser les tests existants
- Nécessiter une autre MR pour que l'app fonctionne
- Laisser des imports orphelins ou du code mort

Concrètement, la spec doit contenir dans "technicalNotes" ou "nonGoals" une
déclaration du type :
- "This MR is independently mergeable — the app compiles and runs without other pending MRs"
- "New code is additive only — no existing behavior is modified"
- "Feature is behind a flag / not yet wired into navigation" (acceptable pour du code préparatoire)

Le scoring vérifie la présence de cette déclaration. L'agent doit s'assurer
que c'est vrai en exécutant `build + test` avant de committer.

### Bonus (plafonné à 100 total)

| ID | Check | Poids | Passe si... |
|----|-------|-------|-------------|
| B1 | `patterns_referenced` | 5 | Au moins 1 pattern/convention référencé |
| B2 | `context_provided` | 3 | Section "Contexte" non vide |
| B3 | `technical_notes` | 2 | Section "Notes techniques" non vide |

---

## Calcul

```
base  = C1 + C2 + C3 + C4          (max 50)
      + CL1 + CL2                   (max 20, cascade depuis C1/C3)
      + T1 + T2                     (max 15, cascade depuis C3)
      + S1 + S2 + S3                (max 20)
      + B1 + B2 + B3                (max 10)
                                     -------
                                     max 115 avant cap

score = min(100, base)
```

### Règle de cascade

Les checks de clarity/testability dépendent des checks de completeness :
- Si C1 fail → CL1 = N/A (0 points)
- Si C3 fail → CL2, T1, T2 = N/A (0 points)

Ça évite qu'une spec vide obtienne des points fantômes.

### Grading

| Grade | Range | Signification | Nuitéfix ? |
|-------|-------|---------------|------------|
| A | 90-100 | Haute confiance | ✅ |
| B | 80-89 | Améliorations mineures | ✅ |
| C | 60-79 | Améliorations nécessaires | ❌ |
| D | 40-59 | Réécriture nécessaire | ❌ |
| F | 0-39 | Squelette seulement | ❌ |

---

## Analyse Ollama (Niveau 2)

Optionnel. `⌘⇧S` dans Specautomatix.

### Vérifie

1. **Ambiguïtés sémantiques** — phrases interprétables de plusieurs façons
2. **Contexte manquant** — infos implicites qu'un agent ne devinerait pas
3. **Cohérence interne** — critères vs description
4. **Suggestion de split** — plusieurs préoccupations détectées

### Prompt template

```
You are a spec quality analyzer for AI coding agents.
Analyze the following spec and identify issues that would cause
Claude Code (Sonnet, headless, --dangerously-skip-permissions)
to fail or produce incorrect results.
NO human intervention during execution.

SPEC:
---
{spec_as_markdown}
---

Respond ONLY in JSON:
{
  "ambiguities": ["phrase + why ambiguous"],
  "missing_context": ["implicit assumption needing explicit statement"],
  "coherence_issues": ["contradiction or inconsistency"],
  "split_suggestions": [
    { "reason": "...", "proposed_titles": ["Sub-spec 1", "Sub-spec 2"] }
  ],
  "overall_quality": "2-sentence assessment"
}
```

---

## Exemples

### mock-001 (French locale) → 100 → A ✅ Nuitéfix ready

| Check | Pts | |
|-------|-----|--|
| C1-C4 | 50/50 | ✅ Tout rempli |
| CL1-CL2 | 20/20 | ✅ Clair, G/W/T complets |
| T1-T2 | 15/15 | ✅ happy + error + edge, Then concrets |
| S1-S2 | 15/15 | ✅ 3 non-goals, estimate = 1 |
| B1-B3 | 10/10 | ✅ Patterns, contexte, notes |
| **Total** | **100** | **A** |

### mock-004 (Add new chart type) → 0 → F ❌

| Check | Pts | |
|-------|-----|--|
| C1 | 0 | ❌ < 50 chars |
| C2-C4 | 0 | ❌ Rien |
| CL1-CL2 | N/A | ⚠️ Cascade |
| T1-T2 | N/A | ⚠️ Cascade |
| S1-S2 | 0 | ❌ Rien, estimate = 5 |
| B1-B3 | 0 | ❌ Rien |
| **Total** | **0** | **F** |

Specautomatix dirait :
- "Décrivez le comportement attendu en détail (> 50 caractères)."
- "Listez les fichiers à modifier."
- "Ajoutez au moins 2 critères Given/When/Then."
- "Précisez ce que l'agent ne doit PAS faire."
- "Estimate de 5 → utilisez le split."