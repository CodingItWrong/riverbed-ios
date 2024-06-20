@testable import Riverbed
import XCTest

final class EditColumnViewControllerTests: XCTestCase {
    
    private var fieldA: Element!
    private var fieldB: Element!
    
    private var sut: EditColumnViewController!
    private var attributes: Column.Attributes!
    
    override func setUp() {
        super.setUp()
        

        fieldA = Element(id: "field_a_id",
                         attributes: Element.Attributes(elementType: .field,
                                                        name: "Field A"))
        fieldB = Element(id: "field_b_id",
                         attributes: Element.Attributes(elementType: .field,
                                                        dataType: .number,
                                                        name: "Field B"))
                
        attributes = Column.Attributes(name: "Initial Name",
                                       cardInclusionConditions: [],
                                       cardGrouping:  Column.SortOrder(field: fieldA.id,
                                                                       direction: .descending),
                                       cardSortOrder: Column.SortOrder(field: fieldB.id,
                                                                       direction: .ascending),
                                       displayOrder: 0,
                                       summary: Column.Summary(function: .sum,
                                                               field: fieldB.id))

        sut = EditColumnViewController()
        sut.elements = [fieldA, fieldB]
        sut.attributes = attributes
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_numberOfRowsInSection_returns5() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 5)
    }
    
    func test_cellForRowAt_withRow0_returnsNameCell() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Column Name")
        XCTAssertEqual(cell.textField.text, attributes.name)
    }
    
    func test_cellForRowAt_withRow1AndNoConditions_returnsCardsToIncludeCellSayingAllCards() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! ButtonCell
        
        XCTAssertEqual(cell.label.text, "Cards to Include")
        XCTAssertEqual(cell.button.title(for: .normal), "All cards")
    }
    
    func test_cellForRowAt_withRow1And1Condition_returnsCardsToIncludeCellSaying1Condition() {
        attributes.cardInclusionConditions = [Condition(field: fieldA.id, query: .isNotEmpty)]
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! ButtonCell
        
        XCTAssertEqual(cell.button.title(for: .normal), "1 condition")
    }
    
    func test_cellForRowAt_withRow1And2Conditions_returnsCardsToIncludeCellSaying2Conditions() {
        attributes.cardInclusionConditions = [
            Condition(field: fieldA.id, query: .isNotEmpty),
            Condition(field: fieldB.id, query: .isNotEmpty),
        ]
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! ButtonCell
        
        XCTAssertEqual(cell.button.title(for: .normal), "2 conditions")
    }
    
    func test_cellForRowAt_withRow2_returnsSortByCell() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! SortByCell
        
        XCTAssertEqual(cell.label.text, "Sort Order")
        XCTAssertEqual(cell.fieldButton.title(for: .normal), "Field B")
        XCTAssertEqual(cell.directionButton.title(for: .normal), "Ascending")
    }
    
    func test_cellForRowAt_withRow2AndNoSort_returnsSortByCellWithDefaults() {
        attributes.cardSortOrder = nil
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! SortByCell
        
        XCTAssertEqual(cell.fieldButton.title(for: .normal), "(field)")
        XCTAssertEqual(cell.directionButton.title(for: .normal), "(direction)")
    }
    
    func test_cellForRowAt_withRow3_returnsGroupByCell() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as! SortByCell
        
        XCTAssertEqual(cell.label.text, "Grouping")
        XCTAssertEqual(cell.fieldButton.title(for: .normal), "Field A")
        XCTAssertEqual(cell.directionButton.title(for: .normal), "Descending")
    }
    
    func test_cellForRowAt_withRow3AndNoGroup_returnsGroupByCellWithDefaults() {
        attributes.cardGrouping = nil
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as! SortByCell
        
        XCTAssertEqual(cell.fieldButton.title(for: .normal), "(field)")
        XCTAssertEqual(cell.directionButton.title(for: .normal), "(direction)")
    }
    
    func test_cellForRowAt_withRow4AndNoFunction_returnsSummaryCellWithNoField() {
        attributes.summary = Column.Summary(function: nil, field: fieldB.id)
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 4, section: 0)) as! SummaryCell
        
        XCTAssertEqual(cell.label.text, "Summary")
        XCTAssertEqual(cell.functionButton.title(for: .normal), "(function)")
        XCTAssertTrue(cell.fieldButton.isHidden)
    }

    func test_cellForRowAt_withRow4AndCountFunction_returnsSummaryCellWithNoField() {
        attributes.summary = Column.Summary(function: .count)
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 4, section: 0)) as! SummaryCell
        
        XCTAssertEqual(cell.functionButton.title(for: .normal), "Count")
        XCTAssertTrue(cell.fieldButton.isHidden)
    }
    
    func test_cellForRowAt_withRow4AndSumFunction_returnsSummaryCellWithField() {
        attributes.summary = Column.Summary(function: .sum, field: fieldB.id)
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 4, section: 0)) as! SummaryCell
        
        XCTAssertEqual(cell.functionButton.title(for: .normal), "Sum")
        XCTAssertFalse(cell.fieldButton.isHidden)
        XCTAssertEqual(cell.fieldButton.title(for: .normal), "Field B")
    }
    
    func test_valueDidChangeInFormCellAt_withRow0_updatesName() {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        let updatedName = "Updated Name"
        
        cell.textField.text = updatedName
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(attributes.name, updatedName)
    }
    
    func test_valueDidChangeInFormCellAt_withRow2_updatesSortOrder() {
        attributes.cardSortOrder = Column.SortOrder(field: fieldA.id, direction: .ascending)
        let updatedField = fieldB!
        let updatedDirection = Column.Direction.descending
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! SortByCell
        
        cell.selectedField = updatedField
        cell.selectedDirection = updatedDirection
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(attributes.cardSortOrder?.field, updatedField.id)
        XCTAssertEqual(attributes.cardSortOrder?.direction, updatedDirection)
    }
    
    func test_valueDidChangeInFormCellAt_withRow3_updatesGrouping() {
        attributes.cardGrouping = Column.SortOrder(field: fieldA.id, direction: .ascending)
        let updatedField = fieldB!
        let updatedDirection = Column.Direction.descending
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! SortByCell
        
        cell.selectedField = updatedField
        cell.selectedDirection = updatedDirection
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(attributes.cardGrouping?.field, updatedField.id)
        XCTAssertEqual(attributes.cardGrouping?.direction, updatedDirection)
    }
    
    func test_valueDidChangeInFormCellAt_withRow4_updatesSummary() {
        attributes.summary = Column.Summary(function: .count, field: nil)
        let updatedFunction = SummaryFunction.sum
        let updatedField = fieldB!
        let indexPath = IndexPath(row: 4, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! SummaryCell
        
        cell.selectedFunction = updatedFunction
        cell.selectedField = updatedField
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(attributes.summary?.function, updatedFunction)
        XCTAssertEqual(attributes.summary?.field, updatedField.id)
    }
    
    func test_didUpdateConditions_updatesConditions() {
        attributes.cardInclusionConditions = []
        let updatedConditions = [Condition(field: fieldA.id,
                                           query: .equals,
                                           options: Condition.Options(value: .string("hi")))]

        sut.didUpdate(conditions: updatedConditions)
        
        XCTAssertEqual(sut.attributes.cardInclusionConditions, updatedConditions)
    }
        
}
