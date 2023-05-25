import Foundation

class CardStore {
    private let session = URLSession(configuration: .default)

    func all(for board: Board, completion: @escaping (Result<[Card], Error>) -> Void) {
        let url = RiverbedAPI.cardsURL(for: board)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, _, error) in
            let result = self.processCardsResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    func delete(_ card: Card, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = RiverbedAPI.cardURL(for: card)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (_, _, error) in
            OperationQueue.main.addOperation {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        task.resume()
    }

    private func processCardsResponse(data: Data?, error: Error?) -> Result<[Card], Error> {
        guard let data = data else {
            if let error = error {
                return .failure(error)
            } else {
                return .failure(APIError.unknownError)
            }
        }

        do {
            let decoder = JSONDecoder()
            let cardsResponse = try decoder.decode(RiverbedAPI.Response<[Card]>.self, from: data)
            return .success(cardsResponse.data)
        } catch {
            return .failure(error)
        }
    }
}
