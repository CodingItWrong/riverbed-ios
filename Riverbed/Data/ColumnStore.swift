import Foundation

class ColumnStore {
    private let session = URLSession(configuration: .default)
    private let accessToken = "WfH8KbT_F7qPsyQKGVU2uHn05o6vzThuoG078805608"

    func all(for board: Board, completion: @escaping (Result<[Column], Error>) -> Void) {
        let url = RiverbedAPI.columnsURL(for: board)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, _, error) in
            let result = self.processColumnsResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    private func processColumnsResponse(data: Data?, error: Error?) -> Result<[Column], Error> {
        guard let data = data else {
            if let error = error {
                return .failure(error)
            } else {
                return .failure(APIError.unknownError)
            }
        }

        do {
            let decoder = JSONDecoder()
            let boardsResponse = try decoder.decode(RiverbedAPI.Response<[Column]>.self, from: data)
            return .success(boardsResponse.data)
        } catch {
            return .failure(error)
        }
    }
}
