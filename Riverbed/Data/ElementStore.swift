import Foundation

class ElementStore {
    private let session = URLSession(configuration: .default)

    func all(for board: Board, completion: @escaping (Result<[Element], Error>) -> Void) {
        let url = RiverbedAPI.elementsURL(for: board)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, _, error) in
            let result = self.processElementsResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    private func processElementsResponse(data: Data?, error: Error?) -> Result<[Element], Error> {
        guard let data = data else {
            if let error = error {
                return .failure(error)
            } else {
                return .failure(APIError.unknownError)
            }
        }

        do {
            let decoder = JSONDecoder()
            let elementsResponse = try decoder.decode(RiverbedAPI.Response<[Element]>.self, from: data)
            return .success(elementsResponse.data)
        } catch {
            return .failure(error)
        }
    }
}
