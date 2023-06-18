import Foundation

class UserStore: BaseStore {
    func find(_ userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        let url = RiverbedAPI.userURL(for: userId)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, response, error) in
            let result: Result<User, Error> = self.processResult((data, response, error))
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }

    func update(_ user: User,
                with updatedAttributes: User.Attributes,
                completion: @escaping (Result<Void, Error>) -> Void) {
        let url = RiverbedAPI.userURL(for: user.id)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let updatedUser = User(id: user.id, attributes: updatedAttributes)

        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(RiverbedAPI.RequestBody(data: updatedUser))
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { (data, response, error) in
                let result: Result<Void, Error> = self.processVoidResult((data, response, error))
                OperationQueue.main.addOperation {
                    completion(result)
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}