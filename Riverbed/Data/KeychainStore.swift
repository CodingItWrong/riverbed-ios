import Foundation

class KeychainStore {

    enum Identifier: String {
        case accessToken
    }

    enum KeychainError: LocalizedError {
        case itemNotFound
        case duplicateItem
        case unexpectedStatus(OSStatus)
    }

    static private let service = "app.riverbed.ios.keychain"

    func save(token: String, identifier: KeychainStore.Identifier, service: String = service) throws {
        guard let tokenData = token.data(using: .utf8)
        else { preconditionFailure("Could not convert string to data: \(token)") }

        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: identifier.rawValue,
            kSecValueData: tokenData
        ] as [String: Any]

        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess else {
            if status == errSecDuplicateItem {
                throw KeychainError.duplicateItem
            }
            throw KeychainError.unexpectedStatus(status)
        }
    }

    func load(identifier: KeychainStore.Identifier, service: String = service) throws -> String {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: identifier.rawValue,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ] as [String: Any]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                // Technically could make the return optional and return nil here
                // depending on how you like this to be taken care of
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }

        guard let result = result as? Data
        else { preconditionFailure("Unexpected result type \(String(describing: result))") }
        guard let string = String(data: result, encoding: .utf8)
        else { preconditionFailure("Could not convert to string: \(String(describing: result))") }
        return string
    }

    func delete(identifier: KeychainStore.Identifier, service: String = service) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: identifier.rawValue
        ] as [String: Any]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

}
