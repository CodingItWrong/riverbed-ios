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

    func updateDisplayOrders(of elements: [Element],
                             completion: @escaping (Result<[Element], Error>) -> Void) {
        let elementsWithNewDisplayOrders = elements.enumerated().map { (index, element) in
            let attributesWithNewDisplayOrder = Element.Attributes(shallowCloning: element.attributes)
            attributesWithNewDisplayOrder.displayOrder = index
            return Element(id: element.id, attributes: attributesWithNewDisplayOrder)
        }

        update(elements: elementsWithNewDisplayOrders, startIndex: 0, completion: completion)
    }

    private func update(elements: [Element],
                        startIndex: Int,
                        completion: @escaping (Result<[Element], Error>) -> Void) {
        let element = elements[startIndex]

        let url = RiverbedAPI.elementURL(for: element)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(RiverbedAPI.accessToken)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
            let requestBody = try encoder.encode(RiverbedAPI.RequestBody(data: element))
            request.httpBody = requestBody

            let task = session.dataTask(with: request) { [weak self] (data, response, error) in
                guard let self = self else { return }

                let result: Result<Void, Error> = self.processVoidResult((data, response, error))
                switch result {
                case let .failure(error):
                    completion(.failure(error))
                case .success:
                    let nextStartIndex = startIndex + 1
                    if nextStartIndex >= elements.count {
                        completion(.success(elements))
                    } else {
                        self.update(elements: elements, startIndex: nextStartIndex, completion: completion)
                    }
                }
            }
            task.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
