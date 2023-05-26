import Foundation

class CardStore {
    private let session = URLSession(configuration: .default)

    func all(for board: Board, completion: @escaping (Result<[Card], Error>) -> Void) {
        let url = RiverbedAPI.cardsURL(for: board)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, _, error) in
            let result: Result<[Card], Error> = self.processResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    func create(on board: Board, completion: @escaping (Result<Card, Error>) -> Void) {
        let card = NewCard(
            attributes: Card.Attributes(fieldValues: [:]),
            relationships: NewCard.Relationships(
                boardData: JsonApiData(
                    data: JsonApiResourceIdentifier(type: "boards", id: board.id)
                )
            )
        )

        let url = RiverbedAPI.cardsURL()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(RiverbedAPI.RequestBody(data: card))
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { (data, _, error) in
                let result: Result<Card, Error> = self.processResponse(data: data, error: error)
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

    private func processResponse<T: Codable>(data: Data?, error: Error?) -> Result<T, Error> {
        guard let data = data else {
            if let error = error {
                return .failure(error)
            } else {
                return .failure(APIError.unknownError)
            }
        }

        do {
            let decoder = JSONDecoder()
            let cardsResponse = try decoder.decode(RiverbedAPI.Response<T>.self, from: data)
            return .success(cardsResponse.data)
        } catch {
            return .failure(error)
        }
    }
}
