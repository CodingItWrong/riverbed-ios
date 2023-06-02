import Foundation

enum APIError: Error {
    case unknownError
    case serverError(httpStatus: Int, body: String?)
}
