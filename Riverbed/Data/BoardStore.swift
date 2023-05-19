import Foundation

class BoardStore {
    enum BoardError: Error {
        case unknownError
    }

    private static let baseURL = URL(string: "http://localhost:3000")

    private let session = URLSession(configuration: .default)
    private let accessToken = "9TVtzNRoaVlFxISzKIekaQvrt454GsQ92Nu00gS0na8"

    func all(completion: @escaping (Result<[Board], Error>) -> Void) {
        let url = URL(string: "/boards", relativeTo: BoardStore.baseURL)!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, _, error) in
            let result = self.processBoardsResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    private func processBoardsResponse(data: Data?, error: Error?) -> Result<[Board], Error> {
        guard let data = data else {
            if let error = error {
                return .failure(error)
            } else {
                return .failure(BoardError.unknownError)
            }
        }

        do {
            let decoder = JSONDecoder()
            let boardsResponse = try decoder.decode(BoardsResponse.self, from: data)
            return .success(boardsResponse.data)
        } catch {
            return .failure(error)
        }
    }
}

func print(jsonData: Data?) {
    guard let jsonData = jsonData else {
        return
    }

    if let jsonString = String(data: jsonData, encoding: .utf8) {
        print(jsonString)
    }
}

struct BoardsResponse: Codable {
    let data: [Board]
}
