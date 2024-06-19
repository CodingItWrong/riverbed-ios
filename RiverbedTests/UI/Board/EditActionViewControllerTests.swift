@testable import Riverbed
import XCTest

final class EditActionViewControllerTests: XCTestCase {
    
    private var fieldA: Element!
    
    private var sut: EditActionViewController!
    
    override func setUp() {
        super.setUp()
        
        fieldA = Element(id: "field_a_id",
                         attributes: Element.Attributes(elementType: .field,
                                                        name: "Field A"))
        
        sut = EditActionViewController()
        sut.action = Action(field: fieldA.id)
        sut.elements = [fieldA]
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_numberOfRows_whenCommandNone_shouldBe2() {
        sut.action.command = .none
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
    }
    
    func test_numberOfRows_whenCommandSetValue_shouldBe2() {
        sut.action.command = .setValue
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 3)
    }
    
    func test_numberOfRows_whenCommandAddDays_shouldBe2() {
        sut.action.command = .addDays
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 3)
    }
    
    func test_cellForRowAt_withRow0_shouldShowCommand() {
        sut.action.command = .setValue
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Command")
        XCTAssertEqual(cell.selectedValue as? Command, Command.setValue)
    }
    
    func test_cellForRowAt_withRow1_shouldShowField() {
        sut.action.field = fieldA.id
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Field")
        XCTAssertEqual(cell.selectedValue as? Element, fieldA)
    }
    
    func test_cellForRowAt_withRow2AndAddDays_shouldShowDaysToAdd() {
        let numDays = "17"
        
        sut.action.command = .addDays
        sut.action.specificValue = .string(numDays)
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Days to Add")
        XCTAssertEqual(cell.textField.text, numDays)
    }
    
    func test_cellForRowAt_withRow2AndSetValue_shouldShowValuePopUp() {
        sut.action.command = .setValue
        sut.action.value = .now
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Value")
        XCTAssertEqual(cell.selectedValue as? Value, .now)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 4)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "(none)")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "empty")
        XCTAssertEqual(cell.popUpButton.menu?.children[2].title, "now")
        XCTAssertEqual(cell.popUpButton.menu?.children[3].title, "specific value")
    }
    
    func test_cellForRowAt_withRow3AndSetValueToSpecificValue_shouldShowElementCell() {
        let specificValue = "a specific value"
        
        sut.action.command = .setValue
        sut.action.value = .specificValue
        sut.action.specificValue = .string(specificValue)
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as! TextElementCell
        
        XCTAssertEqual(cell.elementLabel.text, fieldA.attributes.name)
        XCTAssertEqual(cell.valueTextField.text, specificValue)
    }
}
