import Foundation

class CardStore {
    private let session = URLSession(configuration: .default)
    private let accessToken = "nKDTc2UUqkascU0g9XzIOGaXF70X1PvYWAHKU2vz2oU"

    func all(for board: Board, completion: @escaping (Result<[Card], Error>) -> Void) {
        let url = RiverbedAPI.cardsURL(for: board)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, _, error) in
            let result = self.processCardsResponse(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
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
