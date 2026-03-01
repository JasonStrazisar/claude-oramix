import Foundation
import Security

/// Wrapper autour du Security framework pour stocker, récupérer et supprimer
/// un token depuis le Keychain. Le token n'est jamais stocké en clair en mémoire
/// persistante : il est converti en Data UTF-8 avant d'être confié à SecItem*.
struct KeychainService {

    // MARK: - Public API

    /// Stocke `token` dans le Keychain pour la clé `service`.
    /// Si une entrée existe déjà (errSecDuplicateItem), elle est mise à jour.
    static func store(token: String, for service: String) {
        guard let data = token.data(using: .utf8) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "claude-oramix.github-token"
        ]

        let attributes: [CFString: Any] = [
            kSecValueData: data
        ]

        let addQuery = query.merging([kSecValueData: data] as [CFString: Any]) { _, new in new }

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        if status == errSecDuplicateItem {
            SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        }
    }

    /// Récupère le token stocké pour `service`, ou `nil` s'il n'existe pas.
    static func retrieve(for service: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "claude-oramix.github-token",
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    /// Supprime l'entrée Keychain associée à `service`.
    static func delete(for service: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: "claude-oramix.github-token"
        ]

        SecItemDelete(query as CFDictionary)
    }
}
