import Foundation

class CardStore: BaseStore {
    func all(for board: Board, completion: @escaping (Result<[Card], Error>) -> Void) {
        let url = RiverbedAPI.cardsURL(for: board)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, response, error) in
            let result: Result<[Card], Error> = self.processResult((data, response, error))
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    func find(_ cardId: String, completion: @escaping (Result<Card, Error>) -> Void) {
        let url = RiverbedAPI.cardURL(for: cardId)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, response, error) in
            let result: Result<Card, Error> = self.processResult((data, response, error))
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    func create(on board: Board, with elements: [Element], completion: @escaping (Result<Card, Error>) -> Void) {
        let initialFieldValues = getInitialValues(forElements: elements)

        let card = NewCard(
            attributes: Card.Attributes(fieldValues: initialFieldValues),
            relationships: NewCard.Relationships(
                boardData: JSONAPI.Data(
                    data: JSONAPI.ResourceIdentifier(type: "boards", id: board.id)
                )
            )
        )

        let url = RiverbedAPI.cardsURL()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(JSONAPI.Data(data: card))
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { (data, response, error) in
                let result: Result<Card, Error> = self.processResult((data, response, error))
                OperationQueue.main.addOperation {
                    completion(result)
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
            let requestBody = try encoder.encode(JSONAPI.Data(data: updatedCard))
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
