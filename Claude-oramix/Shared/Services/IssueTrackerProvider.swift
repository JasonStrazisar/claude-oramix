import Foundation

// MARK: - Protocol

/// Abstraction pour tout système de suivi d'issues (GitHub, Linear, Shortcut, Jira…).
/// Les implémentations concrètes sont définies séparément (ex: GitHubIssueTracker — I4).
protocol IssueTrackerProvider {
    /// Crée une issue et retourne les métadonnées de l'issue créée.
    func createIssue(title: String, body: String) async throws -> CreatedIssue

    /// Ajoute un commentaire sur une issue existante.
    func addComment(issueNumber: Int, body: String) async throws
}

// MARK: - Protocol Extension

extension IssueTrackerProvider {
    /// Implémentation par défaut no-op pour addComment.
    /// Les providers qui ne supportent pas les commentaires peuvent ignorer cette méthode.
    func addComment(issueNumber: Int, body: String) async throws {}
}

// MARK: - CreatedIssue

/// Représente une issue créée avec succès dans le tracker.
struct CreatedIssue: Codable, Equatable {
    /// URL publique de l'issue (ex: "https://github.com/org/repo/issues/42").
    let url: String
    /// Numéro de l'issue dans le tracker.
    let number: Int
}

// MARK: - IssueTrackerError

/// Erreurs pouvant survenir lors des interactions avec un IssueTrackerProvider.
enum IssueTrackerError: Error, Equatable {
    /// Le token d'authentification est absent ou invalide.
    case unauthorized
    /// Une erreur réseau s'est produite (message descriptif inclus).
    case networkError(String)
    /// Le provider n'est pas configuré (token manquant, URL absente, etc.).
    case notConfigured
}
