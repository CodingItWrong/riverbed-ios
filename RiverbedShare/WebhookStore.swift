import UIKit

enum WebhookError: LocalizedError {
    case couldNotLoadAccessToken
    case unexpectedResponseType
    case unexpectedResponseStatus
    
    var errorDescription: String? {
        switch self {
        case .couldNotLoadAccessToken: return "Couldn't load access token"
        case .unexpectedResponseType: return "Unexpected response type received"
        case .unexpectedResponseStatus: return "Unexpected response status"
        }
    }
}

class WebhookStore {

    private let webhookURL = RiverbedAPI.webhookURL()

    private let keychainStore = KeychainStore()

    func postWebhook(bodyDict: [String: String?], completion: @escaping (Result<Void, Error>) -> Void) {
        var accessToken: String!
        do {
            accessToken = try keychainStore.load(identifier: .accessToken)
        } catch {
            completion(.failure(error))
            return
        }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 5.0 // seconds
        let session = URLSession(configuration: sessionConfig)

        var request = URLRequest(url: webhookURL)
        var bodyData: Data
        do {
            bodyData = try JSONSerialization.data(withJSONObject: bodyDict, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(accessToken!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = bodyData

        let task = session.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
            }

            guard let response = response,
                  let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(WebhookError.unexpectedResponseType))
                return
            }

            guard httpResponse.statusCode == 204 else {
                completion(.failure(WebhookError.unexpectedResponseStatus))
                return
            }

            completion(.success(()))
        }
        task.resume()
    }
}
