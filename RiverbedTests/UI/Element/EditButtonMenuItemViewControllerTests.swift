@testable import Riverbed
import XCTest
import ViewControllerPresentationSpy

final class EditButtonMenuItemViewControllerTests: XCTestCase {

    class TestDelegate: EditButtonMenuItemDelegate {
        struct Call: Equatable {
            let item: Element.Item
            let index: Int
            
            static func == (lhs: EditButtonMenuItemViewControllerTests.TestDelegate.Call,
                            rhs: EditButtonMenuItemViewControllerTests.TestDelegate.Call) -> Bool {
                lhs.item == rhs.item
                && lhs.index == rhs.index
            }
        }
        
        var calls: [Call] = []
        
        func didUpdate(item: Riverbed.Element.Item, at index: Int) {
            calls.append(Call(item: item, index: index))
        }
    }
    
    private var fieldA: Element!
    
    private var sut: EditButtonMenuItemViewController!
    private var delegate: TestDelegate!
    private var item: Element.Item!
    private var index: Int!
    
    override func setUp() {
        super.setUp()
        
        fieldA = Element(id: "field_a_id",
                         attributes: Element.Attributes(elementType: .field,
                                                        name: "Field A"))
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        sut = sb.instantiateViewController(withIdentifier: String(describing: EditButtonMenuItemViewController.self)) as? EditButtonMenuItemViewController
        
        let action = Action(command: .setValue,
                            field: fieldA.id,
                            value: .specificValue,
                            specificValue: .string("hi"))
        item = Element.Item(name: "Original Name", actions: [action])
        sut.item = item
        
        index = 17
        sut.index = index
        
        delegate = TestDelegate()
        sut.delegate = delegate
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_viewWillDisappear_callsDelegateDidUpdateItemAt() {
        sut.viewWillDisappear(true)
        
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(item: sut.item, index: index)])
    }
    
    func test_numberOfRowsInSection_returns2() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
    }
    
    func test_cellForRowAt_withRow0_returnsName() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Label")
        XCTAssertEqual(cell.textField.text, item.name)
    }
    
    func test_cellForRowAt_withRow1AndNoActions_returnsButtonSayingNone() {
        item.actions = []
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! ButtonCell
        
        XCTAssertEqual(cell.label.text, "Actions")
        XCTAssertEqual(cell.button.title(for: .normal), "(none)")
    }
    
    func test_cellForRowAt_withRow1And1Action_returnsButtonSaying1Action() {
        item.actions = [Action()]
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! ButtonCell
        
        XCTAssertEqual(cell.label.text, "Actions")
        XCTAssertEqual(cell.button.title(for: .normal), "1 action")
    }
    
    func test_cellForRowAt_withRow1And2Actions_returnsButtonSaying2Actions() {
        item.actions = [Action(), Action()]
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! ButtonCell
        
        XCTAssertEqual(cell.label.text, "Actions")
        XCTAssertEqual(cell.button.title(for: .normal), "2 actions")
    }
    
    @MainActor func test_didPressButtonInFormCellAt_performsSegueToActions() {
        let presentationVerifier = PresentationVerifier()
        putInWindow(sut)
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath)
        
        sut.didPressButton(inFormCell: cell, at: indexPath)

        let actionsVC: ActionsViewController? = presentationVerifier.verify(animated: true, presentingViewController: sut)
        XCTAssertEqual(actionsVC?.actions, item.actions)
        XCTAssertEqual(actionsVC?.elements, sut.elements)
        XCTAssertEqual(actionsVC?.delegate as? EditButtonMenuItemViewController, sut)
    }
    
    func test_valueDidChangeInFormCellAt_withRow0_updatesName() {
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        let updatedName = "Updated Name"
        
        cell.textField.text = updatedName
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.item.name, updatedName)
    }
    
    func test_didUpdateActions_updatesActions() {
        let updatedActions = [Action(command: .addDays,
                                     field: nil,
                                     value: .specificValue,
                                     specificValue: .string("2"))]
        
        XCTAssertNotEqual(sut.item.actions, updatedActions) // precondition
        
        sut.didUpdate(actions: updatedActions)
        
        XCTAssertEqual(sut.item.actions, updatedActions)
    }
}
