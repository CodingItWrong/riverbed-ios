import Foundation

protocol TokenSource {
    var accessToken: String? { get }
    var userId: String? { get }
}

protocol WritableTokenSource: TokenSource {
    var accessToken: String? { get set }
    var userId: String? { get set }
}
