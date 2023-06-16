import Foundation

protocol TokenSource {
    var accessToken: String? { get }
}

protocol WritableTokenSource: TokenSource {
    var accessToken: String? { get set }
}
