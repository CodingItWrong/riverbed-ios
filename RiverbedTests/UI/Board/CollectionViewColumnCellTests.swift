@testable import Riverbed
import XCTest

final class CollectionViewColumnCellTests: XCTestCase {

    private var sut: CollectionViewColumnCell!

    override func setUp() {
        super.setUp()

        sut = CollectionViewColumnCell()
        sut.title = UILabel()

        // dataSource requires a UICollectionView; use zero-frame so no cells are dequeued
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        sut.dataSource = UICollectionViewDiffableDataSource<
            CollectionViewColumnCell.GroupSection,
            CollectionViewColumnCell.CardCollectionItem
        >(collectionView: collectionView) { _, _, _ in UICollectionViewCell() }
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_settingCards_updatesCardGroups() {
        sut.column = Column(id: "col1", attributes: Column.Attributes())

        sut.cards = [Card(id: "card1"), Card(id: "card2")]

        XCTAssertEqual(sut.cardGroups.count, 1)
        XCTAssertEqual(sut.cardGroups[0].cards.count, 2)
    }

    func test_settingCards_calculatesSummaryCount() {
        sut.column = Column(id: "col1", attributes: Column.Attributes(
            summary: Column.Summary(function: .count)))

        sut.cards = [Card(id: "card1"), Card(id: "card2"), Card(id: "card3")]

        XCTAssertTrue(sut.title.text?.contains("(3)") ?? false,
                      "Expected title to contain '(3)', got '\(sut.title.text ?? "(nil)")'")
    }

    func test_settingCards_doesNotFilterAgainstConditions() {
        // Column with a condition that the cards would NOT match (field is empty)
        let condition = Condition(field: "some_field", query: .isNotEmpty)
        sut.column = Column(id: "col1", attributes: Column.Attributes(
            cardInclusionConditions: [condition]))

        sut.cards = [Card(id: "card1"), Card(id: "card2")]

        let totalCards = sut.cardGroups.reduce(0) { $0 + $1.cards.count }
        XCTAssertEqual(totalCards, 2, "Expected all 2 cards in cardGroups (no re-filtering)")
    }

}
