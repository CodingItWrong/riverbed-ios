@testable import Riverbed
import XCTest
import ViewControllerPresentationSpy

final class ButtonMenuItemsViewControllerTests: XCTestCase {
    
    class TestDelegate: ButtonMenuItemsDelegate {
        struct Call: Equatable {
            let items: [Riverbed.Element.Item]
        }
        
        var calls: [Call] = []
        
        func didUpdate(items: [Riverbed.Element.Item]) {
            calls.append(Call(items: items))
        }
    }
    
    private var sut: ButtonMenuItemsViewController!
    private var delegate: TestDelegate!
    
    private var fieldA: Element!
    private var fieldB: Element!
    private var elements: [Element]!
    private var itemA: Element.Item!
    private var itemB: Element.Item!
    private var items: [Element.Item]!
    
    override func setUp() {
        super.setUp()
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        sut = sb.instantiateViewController(withIdentifier: String(describing: ButtonMenuItemsViewController.self)) as? ButtonMenuItemsViewController
        
        delegate = TestDelegate()
        sut.delegate = delegate
        
        fieldA = Element(id: "field_a_id",
                         attributes: Element.Attributes(elementType: .field))
        fieldB = Element(id: "field_b_id",
                         attributes: Element.Attributes(elementType: .field))
        elements = [fieldA, fieldB]
        sut.elements = elements
        
        itemA = Element.Item(name: "Item A",
                             actions: [Action(command: .setValue,
                                              field: fieldA.id)])
        itemB = Element.Item(name: "Item B",
                             actions: [Action(command: .addDays,
                                              field: fieldB.id,
                                              value: .specificValue,
                                              specificValue: .string("2"))])
        items = [itemA, itemB]
        sut.items = items
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        delegate = nil
        super.tearDown()
    }
    
    func test_numberOfRowsInSection_returnsNumberOfItems() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), items.count)
    }
    
    func test_cellForRowAt_returnsCellWithItemName() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        
        XCTAssertEqual(cell.textLabel?.text, items[1].name)
    }
    
    @MainActor func test_didSelectRowAt_seguesToEditItemVC() {
        let presentationVerifier = PresentationVerifier()
        putInWindow(sut)
        let row = 1
        
        sut.tableView(sut.tableView, didSelectRowAt: IndexPath(row: row, section: 0))
        
        let editItemVC: EditButtonMenuItemViewController? = presentationVerifier.verify(animated: true, presentingViewController: sut)
        XCTAssertNotNil(editItemVC)
        XCTAssertEqual(editItemVC?.item, items[row])
        XCTAssertEqual(editItemVC?.index, row)
        XCTAssertEqual(editItemVC?.elements, elements)
        XCTAssertEqual(editItemVC?.delegate as? ButtonMenuItemsViewController, sut)
    }
    
    func test_moveRowAtTo_resortsItemsAndCallsDelegate() {
        let fromIndex = IndexPath(row: 0, section: 0)
        let toIndex = IndexPath(row: 1, section: 0)
        let reorderedItems: [Element.Item] = [itemB, itemA]
        
        sut.tableView(sut.tableView, moveRowAt: fromIndex, to: toIndex)
        
        XCTAssertEqual(sut.items, reorderedItems)
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(items: reorderedItems)])
    }
    
    func test_commitForRowAt_withDelete_deletesItemAndCallsDelegate() {
        let itemsWithADeleted: [Element.Item] = [itemB]
        
        sut.tableView(sut.tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(sut.items, itemsWithADeleted)
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(items: itemsWithADeleted)])
    }
    
    func test_addItem_addsAnItemAndCallsDelegate() {
        sut.addItem(nil)
        
        XCTAssertEqual(sut.items.count, items.count + 1)
        let newItem = sut.items.last!
        XCTAssertEqual(newItem.name, "")
        XCTAssertNil(newItem.actions)
        
        XCTAssertEqual(delegate.calls.first?.items.count, items.count + 1)
    }
    
    func test_didUpdateItemAt_passesCallOnToOurDelegate() {
        sut.didUpdate(item: itemB, at: 1)
        
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(items: items)])
    }
}
