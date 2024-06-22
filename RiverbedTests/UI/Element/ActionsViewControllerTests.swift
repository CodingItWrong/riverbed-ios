@testable import Riverbed
import XCTest
import ViewControllerPresentationSpy

final class ActionsViewControllerTests: XCTestCase {
    
    class TestDelegate: ActionsDelegate {
        struct Call: Equatable {
            let actions: [Riverbed.Action]
        }
        
        var calls: [Call] = []
        
        func didUpdate(actions: [Riverbed.Action]) {
            calls.append(Call(actions: actions))
        }
    }
    
    private var sut: ActionsViewController!
    private var delegate: TestDelegate!
    
    private var fieldA: Element!
    private var fieldB: Element!
    private var elements: [Element]!
    private var actionA: Action!
    private var actionB: Action!
    private var actions: [Action]!
    
    override func setUp() {
        super.setUp()
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        sut = sb.instantiateViewController(withIdentifier: String(describing: ActionsViewController.self)) as? ActionsViewController
        
        delegate = TestDelegate()
        sut.delegate = delegate
        
        fieldA = Element(id: "field_a_id",
                         attributes: Element.Attributes(elementType: .field,
                                                        dataType: .text,
                                                        name: "Field A"))
        fieldB = Element(id: "field_b_id",
                         attributes: Element.Attributes(elementType: .field,
                                                        dataType: .date,
                                                        name: "Field B"))
        elements = [fieldA, fieldB]
        sut.elements = elements
        
        actionA = Action(command: .setValue,
                         field: fieldA.id,
                         value: .specificValue,
                         specificValue: .string("hi"))
        actionB = Action(command: .addDays,
                         field: fieldB.id,
                         value: .specificValue,
                         specificValue: .string("2"))
        actions = [actionA, actionB]
        sut.actions = actions
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_numberOfRowsInSection_returnsNumberOfActions() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), actions.count)
    }
    
    func test_cellForRowAt_whenNoCommand_showsNotConfigured() {
        sut.actions.first?.command = nil
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "(not configured)")
    }
    
    func test_cellForRowAt_whenNoField_showsNotConfigured() {
        sut.actions.first?.field = nil
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "(not configured)")
    }
    
    func test_cellForRowAt_whenInvalidField_showsNotConfigured() {
        sut.actions.first?.field = "invalid_id"
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "(not configured)")
    }
    
    func test_cellForRowAt_whenUnnamedField_showsUnnamedField() {
        fieldA.attributes.name = nil
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "Set Value (unnamed field) hi")
    }

    func test_cellForRowAt_whenFieldAndAddDaysCommandAndNoSpecificValue_showsSummary() {
        sut.actions.first?.command = .addDays
        sut.actions.first?.value = .specificValue
        sut.actions.first?.specificValue = nil
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "Add Days Field A (empty)")
    }
    
    func test_cellForRowAt_whenFieldAndAddDaysCommandAndSpecificValue_showsSummary() {
        sut.actions.first?.command = .addDays
        sut.actions.first?.value = .specificValue
        sut.actions.first?.specificValue = .string("2")
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "Add Days Field A 2")
    }

    func test_cellForRowAt_whenSetValueToSpecificValue_showsSummary() {
        sut.actions.first?.command = .setValue
        sut.actions.first?.value = .specificValue
        sut.actions.first?.specificValue = .string("hi")
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "Set Value Field A hi")
    }
    
    func test_cellForRowAt_whenSetValueToNil_showsSummary() {
        sut.actions.first?.command = .setValue
        sut.actions.first?.value = .specificValue
        sut.actions.first?.specificValue = nil
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "Set Value Field A (empty)")
    }
    
    func test_cellForRowAt_whenSetValueToNow_showsSummary() {
        sut.actions.first?.command = .setValue
        sut.actions.first?.value = .now
        sut.actions.first?.specificValue = nil
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, "Set Value Field A now")
    }
    
    @MainActor func test_didSelectRowAt_seguesToEdit() {
        let presentationVerifier = PresentationVerifier()
        putInWindow(sut)
        let row = 1
        let indexPath = IndexPath(row: row, section: 0)
        let action = actions[row]
        
        sut.tableView(sut.tableView, didSelectRowAt: indexPath)
        
        let editActionVC: EditActionViewController? = presentationVerifier.verify(animated: true, presentingViewController: sut)
        XCTAssertNotNil(editActionVC)
        XCTAssertEqual(editActionVC?.action, action)
        XCTAssertEqual(editActionVC?.elements, elements)
        XCTAssertEqual(editActionVC?.delegate as? ActionsViewController, sut)
    }
    
    func test_moveRowAtTo_reordersRowsAndCallsDelegate() {
        let fromIndex = IndexPath(row: 0, section: 0)
        let toIndex = IndexPath(row: 1, section: 0)
        let reorderedActions: [Action] = [actionB, actionA]
        
        XCTAssertNotEqual(sut.actions, reorderedActions) // precondition
        
        sut.tableView(sut.tableView, moveRowAt: fromIndex, to: toIndex)
        
        XCTAssertEqual(sut.actions, reorderedActions)
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(actions: reorderedActions)])
    }
    
    func test_commitForRowAt_withDelete_deletesRowAndCallsDelegate() {
        let actionsWithADeleted: [Action] = [actionB]
        
        sut.tableView(sut.tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(sut.actions, actionsWithADeleted)
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(actions: actionsWithADeleted)])
    }
    
    func test_addAction_addsANewActionAndCallsDelegate() {
        sut.addAction(nil)
        
        XCTAssertEqual(sut.actions.count, actions.count + 1)
        let newAction = sut.actions.last
        XCTAssertNil(newAction?.command)
        XCTAssertNil(newAction?.field)
        XCTAssertNil(newAction?.value)
        XCTAssertNil(newAction?.specificValue)
        
        XCTAssertEqual(delegate.calls.count, 1)
        XCTAssertEqual(delegate.calls.first?.actions.count, actions.count + 1)
    }
}
