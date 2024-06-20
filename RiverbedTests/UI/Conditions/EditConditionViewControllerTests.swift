@testable import Riverbed
import XCTest

final class EditConditionViewControllerTests: XCTestCase {
    
    private var fieldA: Element!
    private var fieldB: Element!
    
    private var sut: EditConditionViewController!
    
    override func setUp() {
        super.setUp()
        
        fieldA = Element(id: "field_a_id",
                         attributes: Element.Attributes(elementType: .field,
                                                        name: "Field A"))
        fieldB = Element(id: "field_b_id",
                         attributes: Element.Attributes(elementType: .field,
                                                        name: "Field B"))
        
        sut = EditConditionViewController()
        let options = Condition.Options()
        let condition = Condition()
        condition.query = .equals
        condition.field = fieldA.id
        condition.options = options
        sut.condition = condition
        sut.elements = [fieldA, fieldB]
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_numberOfRows_whenShowConcreteFieldValueAndFieldSet_returns3() {
        sut.condition.query = .equals
        sut.condition.field = fieldA.id
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 3)
    }
    
    func test_numberOfRows_whenShowConcreteFieldValueAndFieldNotSet_returns3() {
        sut.condition.query = .equals
        sut.condition.field = nil
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
    }
    
    func test_numberOfRows_whenNoShowConcreteFieldValue_returns2() {
        sut.condition.query = .isCurrentMonth
        sut.condition.field = fieldA.id // to ensure the result isn't due to this being nil
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
    }
    
    func test_numberOfRows_whenQueryNil_returns2() {
        sut.condition.query = nil
        sut.condition.field = fieldA.id // to ensure the result isn't due to this being nil
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
    }
    
    func test_cellForRowAt_withRow0_shouldShowField() {
        sut.condition.field = fieldB.id
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Field")
        XCTAssertEqual(cell.selectedValue as? Element, fieldB)
    }
    
    func test_cellForRowAt_withRow1_shouldShowQuery() {
        let query = Query.isCurrentMonth
        sut.condition.query = query
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Query")
        XCTAssertEqual(cell.selectedValue as? Query, query)
    }
    
    func test_cellForRowAt_withRow2AndShowConcreteValue_shouldShowConcreteValue() {
        let value = "current_value"
        sut.condition.query = .equals
        sut.condition.options?.value = .string(value)
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! TextElementCell
        
        XCTAssertEqual(cell.elementLabel.text, "Field A")
        XCTAssertEqual(cell.valueTextField.text, value)
    }
    
    func test_updateValueFor_shouldSetValueOption() {
        let value = FieldValue.string("updated value")
        
        sut.update(value: value, for: fieldA)
        
        XCTAssertEqual(sut.condition.options?.value, value)
    }
    
    func test_valueDidChangeInFormCellAt_withRow0_shouldSetField() {
        let updatedField = fieldB!
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! PopUpButtonCell
        
        cell.selectedValue = updatedField
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.condition.field, updatedField.id)
    }
    
    func test_valueDidChangeInFormCellAt_withRow1_shouldSetQuery() {
        let updatedQuery = Query.isNotEmpty
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! PopUpButtonCell
        
        cell.selectedValue = updatedQuery
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.condition.query, updatedQuery)
    }
}
