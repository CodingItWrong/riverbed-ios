import Foundation

class TokenStore: BaseStore {
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

    func update(_ card: Card,
                with fieldValues: [String: FieldValue?],
                completion: @escaping (Result<Void, Error>) -> Void) {
        let url = RiverbedAPI.cardURL(for: card)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let updatedCard = Card(id: card.id, attributes: Card.Attributes(fieldValues: fieldValues))

        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(RiverbedAPI.RequestBody(data: updatedCard))
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { (data, response, error) in
                let result: Result<Void, Error> = self.processVoidResult((data, response, error))
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }

    func delete(_ card: Card, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = RiverbedAPI.cardURL(for: card)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, response, error) in
            let result: Result<Void, Error> = self.processVoidResult((data, response, error))
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
}
