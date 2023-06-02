import Foundation

class ElementStore: BaseStore {
    func all(for board: Board, completion: @escaping (Result<[Element], Error>) -> Void) {
        let url = RiverbedAPI.elementsURL(for: board)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, response, error) in
            let result: Result<[Element], Error> = self.processResult((data, response, error))
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
}
