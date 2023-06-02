import Foundation

class BaseStore {
    let session = URLSession(configuration: .default)

    func processResult<T: Codable>(_ urlResult: (Data?, URLResponse?, Error?)) -> Result<T, Error> {
        let (data, response, error) = urlResult

        // error reported by URLSession
        if let error = error { return .failure(error) }

        // server error
        guard let response = response as? HTTPURLResponse else { return .failure(APIError.unknownError) }
        if response.statusCode >= 400 {
            if let data = data,
               let bodyString = String(data: data, encoding: .utf8) {
                return .failure(APIError.serverError(httpStatus: response.statusCode, body: bodyString))
            } else {
                return .failure(APIError.serverError(httpStatus: response.statusCode, body: nil))
            }
        }

        // error getting data
        guard let data = data else {
            return .failure(APIError.unknownError)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateTimeUtils.serverDateTimeFormatter)
            let cardsResponse = try decoder.decode(RiverbedAPI.Response<T>.self, from: data)
            return .success(cardsResponse.data)
        } catch {
            return .failure(error)
        }
    }

    func processVoidResult(_ urlResult: (Data?, URLResponse?, Error?)) -> Result<Void, Error> {
        let (data, response, error) = urlResult

        // error reported by URLSession
        if let error = error { return .failure(error) }

        // server error
        guard let response = response as? HTTPURLResponse else { return .failure(APIError.unknownError) }
        if response.statusCode >= 400 {
            if let data = data,
               let bodyString = String(data: data, encoding: .utf8) {
                return .failure(APIError.serverError(httpStatus: response.statusCode, body: bodyString))
            } else {
                return .failure(APIError.serverError(httpStatus: response.statusCode, body: nil))
            }
        }

        return .success(())
    }

}
