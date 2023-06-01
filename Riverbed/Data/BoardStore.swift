import Foundation

class BoardStore {
    private let session = URLSession(configuration: .default)

    func all(completion: @escaping (Result<[Board], Error>) -> Void) {
        let url = RiverbedAPI.boardsURL()
        var request = URLRequest(url: url)
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, _, error) in
            print(jsonData: data)
            let result: Result<[Board], Error> = self.processResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    func create(completion: @escaping (Result<Board, Error>) -> Void) {
        let url = RiverbedAPI.boardsURL()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let newBoard = NewBoard(attributes: Board.Attributes())

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(DateTimeUtils.serverDateTimeFormatter)
            let requestBody = try encoder.encode(RiverbedAPI.RequestBody(data: newBoard))
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { (data, _, error) in
                let result: Result<Board, Error> = self.processResponse(data: data, error: error)
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }

    func update(_ board: Board,
                with updatedAttributes: Board.Attributes,
                completion: @escaping (Result<Void, Error>) -> Void) {
        let url = RiverbedAPI.boardURL(board)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let updatedBoard = Board(id: board.id, attributes: updatedAttributes)

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(DateTimeUtils.serverDateTimeFormatter)
            let requestBody = try encoder.encode(RiverbedAPI.RequestBody(data: updatedBoard))
            request.httpBody = requestBody

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
        } catch {
            completion(.failure(error))
        }
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
            decoder.dateDecodingStrategy = .formatted(DateTimeUtils.serverDateTimeFormatter)
            let cardsResponse = try decoder.decode(RiverbedAPI.Response<T>.self, from: data)
            return .success(cardsResponse.data)
        } catch {
            return .failure(error)
        }
    }
}
