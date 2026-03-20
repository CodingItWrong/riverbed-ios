@testable import Riverbed
import Foundation

private class MockSessionSource: SessionSource {
    var accessToken: String? = nil
    var userId: String? = nil
}

class MockCardStore: CardStore {
    init() {
        super.init(sessionSource: MockSessionSource())
    }
}
