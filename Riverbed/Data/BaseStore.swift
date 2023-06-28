import Foundation

class BaseStore {
    let session = URLSession(configuration: .default)

    private var sessionSource: SessionSource
    var accessToken: String {
        sessionSource.accessToken ?? "" // to avoid optional in string interpolation
    }

    init(sessionSource: SessionSource) {
        self.sessionSource = sessionSource
    }

    func processResult<T: Codable>(_ urlResult: (Data?, URLResponse?, Error?),
                                   isRiverbedResponse: Bool = true) -> Result<T, Error> {
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
            if isRiverbedResponse {
                let cardsResponse = try decoder.decode(JSONAPI.Data<T>.self, from: data)
                return .success(cardsResponse.data)
            } else {
                let cardsResponse = try decoder.decode(T.self, from: data)
                return .success(cardsResponse)
            }
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
