import Foundation

class KeychainTokenSource: WritableTokenSource {

    private var keychainStore: KeychainStore
    private var isInitialized = false

    init(keychainStore: KeychainStore) {
        self.keychainStore = keychainStore
        loadFromKeychain()
        isInitialized = true
    }

    var accessToken: String? {
        didSet {
            if !isInitialized { return }
            if let accessToken = accessToken {
                saveToKeychain(accessToken)
            } else {
                deleteFromKeychain()
            }
        }
    }

    private func loadFromKeychain() {
        do {
            self.accessToken = try keychainStore.load(identifier: .accessToken)
        } catch {
            if let error = error as? KeychainStore.KeychainError {
                switch error {
                case .itemNotFound:
                    print("User not signed in")
                case .duplicateItem:
                    preconditionFailure("Did not expect a duplicate item")
                case let .unexpectedStatus(status):
                    print("Unexpected status: \(status)")
                }
            } else {
                print("Error loading access token: \(String(describing: error))")
            }
        }
    }

    private func saveToKeychain(_ newValue: String) {
        do {
            try keychainStore.save(token: newValue, identifier: .accessToken)
        } catch {
            if let error = error as? KeychainStore.KeychainError {
                switch error {
                case .itemNotFound:
                    preconditionFailure("Did not expect an item not found error")
                case .duplicateItem:
                    preconditionFailure("Already have an access token stored")
                case let .unexpectedStatus(status):
                    print("Unexpected status: \(status)")
                }
            } else {
                print("Error saving access token: \(String(describing: error))")
            }
        }
    }

    private func deleteFromKeychain() {
        do {
            try keychainStore.delete(identifier: .accessToken)
        } catch {
            if let error = error as? KeychainStore.KeychainError {
                switch error {
                case .itemNotFound:
                    preconditionFailure("No access token to delete")
                case .duplicateItem:
                    preconditionFailure("Did not expect a duplicate item")
                case let .unexpectedStatus(status):
                    print("Unexpected status: \(status)")
                }
            } else {
                print("Error deleting access token: \(String(describing: error))")
            }
        }
    }
}
