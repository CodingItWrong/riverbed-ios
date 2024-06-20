@testable import Riverbed
import Foundation

class MockTokenStore: TokenStore {
    struct CreateCall {
        let email: String
        let password: String
    }
    
    var createCalls: [CreateCall] = []
    
    var createResult: Result<Riverbed.TokenResponse, any Error>
        = .success(TokenResponse(accessToken: "fake_access_token",
                                 tokenType: "fake_token_type",
                                 createdAt: 1718885326,
                                 userId: 1))
    
    func create(email: String, password: String, completion: @escaping (Result<Riverbed.TokenResponse, any Error>) -> Void) {
        createCalls.append(CreateCall(email: email, password: password))
        
        completion(createResult)
    }
}
