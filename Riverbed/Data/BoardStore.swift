import Foundation

class BoardStore {
    private let session = URLSession(configuration: .default)

    func all(completion: @escaping (Result<[Board], Error>) -> Void) {
        let url = RiverbedAPI.boardsURL()
        var request = URLRequest(url: url)
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, _, error) in
            print(jsonData: data)
            let result = self.processBoardsResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
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
            print(jsonData: requestBody)
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { (data, _, error) in
                print(jsonData: data)
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

    private func processBoardsResponse(data: Data?, error: Error?) -> Result<[Board], Error> {
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
            let boardsResponse = try decoder.decode(RiverbedAPI.Response<[Board]>.self, from: data)
            return .success(boardsResponse.data)
        } catch {
            return .failure(error)
        }
    }
}
