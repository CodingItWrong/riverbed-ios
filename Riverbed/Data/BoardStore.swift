import Foundation

class BoardStore {
    private let session = URLSession(configuration: .default)
    private let accessToken = "nKDTc2UUqkascU0g9XzIOGaXF70X1PvYWAHKU2vz2oU"

    func all(completion: @escaping (Result<[Board], Error>) -> Void) {
        let url = RiverbedAPI.boardsURL()
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
                return .failure(APIError.unknownError)
            }
        }

        do {
            let decoder = JSONDecoder()
            let boardsResponse = try decoder.decode(RiverbedAPI.Response<[Board]>.self, from: data)
            return .success(boardsResponse.data)
        } catch {
            return .failure(error)
        }
    }
}
