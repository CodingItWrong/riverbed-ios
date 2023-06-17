import Foundation

protocol SessionSource {
    var accessToken: String? { get }
    var userId: String? { get }
}

protocol WritableSessionSource: SessionSource {
    var accessToken: String? { get set }
    var userId: String? { get set }
}
