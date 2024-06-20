import Foundation

struct TokenResponse: Codable {
    var accessToken: String
    var tokenType: String
    var createdAt: Int
    var userId: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case createdAt = "created_at"
        case userId = "user_id"
    }
}

protocol TokenStore {
    func create(email: String, password: String, completion: @escaping (Result<TokenResponse, Error>) -> Void)
}

class ApiTokenStore: BaseStore, TokenStore {
    struct CreateTokenRequest: Codable {
        var grantType: String
        var username: String
        var password: String

        init(username: String, password: String, grantType: String = "password") {
            self.grantType = grantType
            self.username = username
            self.password = password
        }

        enum CodingKeys: String, CodingKey {
            case grantType = "grant_type"
            case username
            case password
        }
    }

    func create(email: String, password: String, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        let url = RiverbedAPI.tokensURL()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let createTokenRequest = CreateTokenRequest(username: email, password: password)

        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(createTokenRequest)
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { (data, response, error) in
                let result: Result<TokenResponse, Error> =
                    self.processResult((data, response, error), isRiverbedResponse: false)
                OperationQueue.main.addOperation {
                    switch result {
                    case let .failure(error):
                        completion(.failure(error))
                    case let .success(response):
                        completion(.success(response))
                    }
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
