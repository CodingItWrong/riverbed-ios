import Foundation

protocol UserStore {
    func find(_ userId: String, completion: @escaping (Result<User, Error>) -> Void)
    
    func create(with attributes: NewUser.Attributes, completion: @escaping (Result<Void, Error>) -> Void)
    
    func update(_ user: User,
                with updatedAttributes: User.Attributes,
                completion: @escaping (Result<Void, Error>) -> Void)
    
    func delete(_ user: User, completion: @escaping (Result<Void, Error>) -> Void)
}

class ApiUserStore: BaseStore, UserStore {
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

    func create(with attributes: NewUser.Attributes, completion: @escaping (Result<Void, Error>) -> Void) {
        let user = NewUser(attributes: attributes)

        let url = RiverbedAPI.usersURL()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(JSONAPI.Data(data: user))
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
            let requestBody = try encoder.encode(JSONAPI.Data(data: updatedUser))
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

    func delete(_ user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = RiverbedAPI.userURL(for: user.id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = session.dataTask(with: request) { (data, response, error) in
            let result: Result<Void, Error> = self.processVoidResult((data, response, error))
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
}
