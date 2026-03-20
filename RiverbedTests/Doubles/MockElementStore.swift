@testable import Riverbed
import Foundation

private class MockSessionSource: SessionSource {
    var accessToken: String? = nil
    var userId: String? = nil
}

class MockElementStore: ElementStore {
    var allResult: Result<[Element], Error>?

    init() {
        super.init(sessionSource: MockSessionSource())
    }

    override func all(for board: Board, completion: @escaping (Result<[Element], Error>) -> Void) {
        if let result = allResult { completion(result) }
    }
}
