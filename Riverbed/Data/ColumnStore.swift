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

    func create(on board: Board, completion: @escaping (Result<Column, Error>) -> Void) {
        let url = RiverbedAPI.columnsURL()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let newBoard = NewColumn(
            attributes: Column.Attributes(),
            relationships: NewColumn.Relationships(
                boardData: JsonApiData(
                    data: JsonApiResourceIdentifier(type: "boards", id: board.id)
                )
            )
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(DateTimeUtils.serverDateTimeFormatter)
            let requestBody = try encoder.encode(RiverbedAPI.RequestBody(data: newBoard))
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { (data, response, error) in
                let result: Result<Column, Error> = self.processResult((data, response, error))
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }

    func delete(_ column: Column, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = RiverbedAPI.columnURL(for: column.id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, response, error) in
            let result: Result<Void, Error> = self.processVoidResult((data, response, error))
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
}
