@testable import Riverbed
import XCTest

final class EditBoardViewControllerTests: XCTestCase {
    
    private var sut: EditBoardViewController!
    
    override func setUp() {
        super.setUp()
        sut = EditBoardViewController()
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func test_numberOfRows_shouldBe7() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 7)
    }
    
    func test_cellForRowAt_withRow0_shouldConfigureBoardNameCell() {
        let boardName = "Fake Board Name"
        sut.attributes = Board.Attributes(name: boardName)

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Board Name")
        XCTAssertEqual(cell.textField.text, boardName)
        XCTAssertNotNil(cell.textField.delegate) // can't test for equality with sut for some reason
    }
    
    func test_cellForRowAt_withRow1_shouldConfigureColorThemeCell() {
        let colorTheme = ColorTheme.pink
        sut.attributes = Board.Attributes(colorTheme: colorTheme)

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Color Theme")
        XCTAssertEqual(cell.selectedValue as! ColorTheme, colorTheme)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 9)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "Default")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "Red")
        XCTAssertEqual(cell.popUpButton.menu?.children[2].title, "Orange")
        XCTAssertEqual(cell.popUpButton.menu?.children[3].title, "Yellow")
        XCTAssertEqual(cell.popUpButton.menu?.children[4].title, "Green")
        XCTAssertEqual(cell.popUpButton.menu?.children[5].title, "Cyan")
        XCTAssertEqual(cell.popUpButton.menu?.children[6].title, "Blue")
        XCTAssertEqual(cell.popUpButton.menu?.children[7].title, "Pink")
        XCTAssertEqual(cell.popUpButton.menu?.children[8].title, "Purple")
    }
    
    func test_cellForRowAt_withRow2_shouldConfigureIconCell() {
        let icon = Icon.book
        sut.attributes = Board.Attributes(iconName: icon.rawValue)

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Icon")
        XCTAssertEqual(cell.selectedValue as! Icon, icon)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 16)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "(none)")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "Baseball")
    }
    
    func test_cellForRowAt_withRow3_shouldConfigureCardCreateWebhookCell() {
        // TODO: simplify initalization
        let webhooks = Board.Webhooks()
        webhooks.cardCreate = "fake card create URL"
        let options = Board.Options()
        options.webhooks = webhooks
        sut.attributes = Board.Attributes(options: options)

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Card Create Webhook")
        XCTAssertEqual(cell.textField.text, webhooks.cardCreate)
    }
    
    func test_cellForRowAt_withRow4_shouldConfigureCardUpdateWebhookCell() {
        // TODO: simplify initalization
        let webhooks = Board.Webhooks()
        webhooks.cardUpdate = "fake card update URL"
        let options = Board.Options()
        options.webhooks = webhooks
        sut.attributes = Board.Attributes(options: options)

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 4, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Card Update Webhook")
        XCTAssertEqual(cell.textField.text, webhooks.cardUpdate)
    }
    
    func test_cellForRowAt_withRow5_shouldConfigureShareUrlCell() {
        let urlField = Element(id: "url_field_id", attributes: Element.Attributes(elementType: .field, name: "URL"))
        let titleField = Element(id: "title_field_id", attributes: Element.Attributes(elementType: .field, name: "Title"))
        sut.fields = [urlField, titleField]
        let share = Board.Share()
        share.urlField = urlField.id
        let options = Board.Options()
        options.share = share
        sut.attributes = Board.Attributes(options: options)

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 5, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Share URL Field")
        XCTAssertEqual(cell.selectedValue as! Element, urlField)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 3)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "(none)")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "URL")
        XCTAssertEqual(cell.popUpButton.menu?.children[2].title, "Title")
    }

    func test_cellForRowAt_withRow6_shouldConfigureShareTitleCell() {
        let urlField = Element(id: "url_field_id", attributes: Element.Attributes(elementType: .field, name: "URL"))
        let titleField = Element(id: "title_field_id", attributes: Element.Attributes(elementType: .field, name: "Title"))
        sut.fields = [urlField, titleField]
        let share = Board.Share()
        share.titleField = titleField.id
        let options = Board.Options()
        options.share = share
        sut.attributes = Board.Attributes(options: options)

        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 6, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Share Title Field")
        XCTAssertEqual(cell.selectedValue as! Element, titleField)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 3)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "(none)")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "URL")
        XCTAssertEqual(cell.popUpButton.menu?.children[2].title, "Title")
    }
    
    func test_valueDidChangeInFormCell_withRow0_shouldSetBoardName() {
        sut.attributes = Board.Attributes(name: "original board name")
        let updatedBoardName = "updated board name"
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TextFieldCell
        cell.textField.text = updatedBoardName
        
        RunLoop.current.run(until: Date.now)
        sut.valueDidChange(inFormCell: sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)))
        RunLoop.current.run(until: Date.now)

        // TODO: it's not finding the index path by the cell
        XCTAssertEqual(updatedBoardName, sut.attributes.name)
    }
}
