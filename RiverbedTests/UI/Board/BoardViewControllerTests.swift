@testable import Riverbed
import XCTest

final class BoardViewControllerTests: XCTestCase {

    private var sut: BoardViewController!
    private var columnStore: MockColumnStore!
    private var elementStore: MockElementStore!

    override func setUp() {
        super.setUp()

        let sb = UIStoryboard(name: "Main", bundle: nil)
        sut = sb.instantiateViewController(
            withIdentifier: String(describing: BoardViewController.self)) as? BoardViewController

        columnStore = MockColumnStore()
        sut.columnStore = columnStore

        elementStore = MockElementStore()
        elementStore.allResult = .success([])
        sut.elementStore = elementStore

        sut.cardStore = MockCardStore()
        sut.boardStore = MockBoardStore()

        putInWindow(sut)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_loadBoardData_fetchesFilteredCardsPerColumn() {
        let col1 = Column(id: "col1", attributes: Column.Attributes(name: "Col 1"))
        let col2 = Column(id: "col2", attributes: Column.Attributes(name: "Col 2"))
        columnStore.allResult = .success([col1, col2])

        let card1 = Card(id: "card1")
        let card2 = Card(id: "card2")
        columnStore.cardsResults["col1"] = .success([card1])
        columnStore.cardsResults["col2"] = .success([card2])

        sut.board = Board(id: "board1", attributes: Board.Attributes())

        XCTAssertEqual(sut.columnCards["col1"]?.map { $0.id }, ["card1"])
        XCTAssertEqual(sut.columnCards["col2"]?.map { $0.id }, ["card2"])
    }

    func test_loadBoardData_whenColumnHasNoCards_storesEmptyArray() {
        let col1 = Column(id: "col1", attributes: Column.Attributes(name: "Col 1"))
        columnStore.allResult = .success([col1])
        columnStore.cardsResults["col1"] = .success([])

        sut.board = Board(id: "board1", attributes: Board.Attributes())

        XCTAssertEqual(sut.columnCards["col1"], [])
    }

    func test_loadBoardData_whenColumnLoadFails_showsError() {
        let col1 = Column(id: "col1", attributes: Column.Attributes(name: "Col 1"))
        columnStore.allResult = .success([col1])
        columnStore.cardsResults["col1"] = .failure(APIError.unknownError)

        sut.board = Board(id: "board1", attributes: Board.Attributes())

        XCTAssertTrue(sut.errorContainer.isHidden == false)
        XCTAssertEqual(sut.columnCards.count, 0)
    }

    func test_loadBoardData_whenColumnsLoadFails_doesNotLoadCards() {
        columnStore.allResult = .failure(APIError.unknownError)

        sut.board = Board(id: "board1", attributes: Board.Attributes())

        XCTAssertTrue(sut.columnCards.isEmpty)
    }

}
