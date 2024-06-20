@testable import Riverbed
import Foundation

class MockUserStore: UserStore {
    enum Call {
        case find (userId: String)
        case create (attributes: Riverbed.NewUser.Attributes)
        case update (user: Riverbed.User, attributes: Riverbed.User.Attributes)
        case delete (user: Riverbed.User)
    }
    
    var calls: [Call] = []
    
    var findResult: Result<Riverbed.User, any Error>? = nil
    var createResult: Result<Void, any Error>? = nil
    var updateResult: Result<Void, any Error>? = nil
    var deleteResult: Result<Void, any Error>? = nil
    
    func find(_ userId: String, completion: @escaping (Result<Riverbed.User, any Error>) -> Void)
    {
        calls.append(.find(userId: userId))
        
        if let result = findResult {
            completion(result)
        }
    }
    
    func create(with attributes: Riverbed.NewUser.Attributes, completion: @escaping (Result<Void, any Error>) -> Void)
    {
        calls.append(.create(attributes: attributes))
        
        if let result = createResult {
            completion(result)
        }
    }
    
    func update(_ user: Riverbed.User, with updatedAttributes: Riverbed.User.Attributes, completion: @escaping (Result<Void, any Error>) -> Void)
    {
        calls.append(.update(user: user, attributes: updatedAttributes))
        
        if let result = updateResult {
            completion(result)
        }
    }
    
    func delete(_ user: Riverbed.User, completion: @escaping (Result<Void, any Error>) -> Void)
    {
        calls.append(.delete(user: user))
        
        if let result = deleteResult {
            completion(result)
        }
    }
}
