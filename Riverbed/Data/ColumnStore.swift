import Foundation

class ColumnStore: BaseStore {
    func all(for board: Board, completion: @escaping (Result<[Column], Error>) -> Void) {
        let url = RiverbedAPI.columnsURL(for: board)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, response, error) in
            let result: Result<[Column], Error> = self.processResult((data, response, error))
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
}
