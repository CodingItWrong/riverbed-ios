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
        sut.condition = Condition()
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
}
