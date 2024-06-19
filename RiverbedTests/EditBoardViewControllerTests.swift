@testable import Riverbed
import XCTest

final class EditBoardViewControllerTests: XCTestCase {
    
    private var attributes: Board.Attributes!
    private var urlField: Element!
    private var titleField: Element!
    private var sut: EditBoardViewController!
    
    override func setUp() {
        super.setUp()
        sut = EditBoardViewController()
        
        urlField = Element(id: "url_field_id", attributes: Element.Attributes(elementType: .field, name: "URL"))
        titleField = Element(id: "title_field_id", attributes: Element.Attributes(elementType: .field, name: "Title"))
        sut.fields = [urlField, titleField]

        let webhooks = Board.Webhooks()
        webhooks.cardCreate = "original card create URL"
        webhooks.cardUpdate = "original card update URL"
        let share = Board.Share()
        share.urlField = urlField.id
        share.titleField = titleField.id
        let options = Board.Options()
        options.webhooks = webhooks
        options.share = share
        attributes = Board.Attributes(name: "original board name",
                                      colorTheme: .red,
                                      options: options)
        sut.attributes = attributes
        
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
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Board Name")
        XCTAssertEqual(cell.textField.text, attributes.name)
        XCTAssertNotNil(cell.textField.delegate) // can't test for equality with sut for some reason
    }
    
    func test_cellForRowAt_withRow1_shouldConfigureColorThemeCell() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Color Theme")
        XCTAssertEqual(cell.selectedValue as? ColorTheme, attributes.colorTheme)
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
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Icon")
        XCTAssertEqual(cell.selectedValue as? Icon, attributes.icon)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 16)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "(none)")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "Baseball")
    }
    
    func test_cellForRowAt_withRow3_shouldConfigureCardCreateWebhookCell() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Card Create Webhook")
        XCTAssertEqual(cell.textField.text, attributes.options?.webhooks?.cardCreate)
    }
    
    func test_cellForRowAt_withRow4_shouldConfigureCardUpdateWebhookCell() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 4, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Card Update Webhook")
        XCTAssertEqual(cell.textField.text, attributes.options?.webhooks?.cardUpdate)
    }
    
    func test_cellForRowAt_withRow5_shouldConfigureShareUrlCell() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 5, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Share URL Field")
        XCTAssertEqual(cell.selectedValue as? Element, urlField)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 3)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "(none)")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "URL")
        XCTAssertEqual(cell.popUpButton.menu?.children[2].title, "Title")
    }

    func test_cellForRowAt_withRow6_shouldConfigureShareTitleCell() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 6, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Share Title Field")
        XCTAssertEqual(cell.selectedValue as? Element, titleField)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 3)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "(none)")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "URL")
        XCTAssertEqual(cell.popUpButton.menu?.children[2].title, "Title")
    }
    
    func test_valueDidChangeInFormCell_withRow0_shouldSetBoardName() {
        let updatedBoardName = "updated board name"
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        
        cell.textField.text = updatedBoardName
        sut.valueDidChange(inFormCell: cell, at: indexPath)

        XCTAssertEqual(sut.attributes.name, updatedBoardName)
    }
    
    func test_valueDidChangeInFormCell_withRow1_shouldSetColorTheme() {
        let updatedColorTheme = ColorTheme.green
        
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! PopUpButtonCell

        XCTAssertNotEqual(sut.attributes.colorTheme, updatedColorTheme) // precondition
        
        cell.selectedValue = updatedColorTheme
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.attributes.colorTheme, updatedColorTheme)
    }
    
    func test_valueDidChangeInFormCell_withRow2_shouldSetSetIcon() {
        let updatedIcon = Icon.food
        
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! PopUpButtonCell

        XCTAssertNotEqual(sut.attributes.icon, updatedIcon) // precondition
        
        cell.selectedValue = updatedIcon
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.attributes.icon, updatedIcon)
    }
    
    func test_valueDidChangeInFormCell_withRow3_shouldSetCardCreateWebhook() {
        let updatedCardCreateWebhook = "updated card create URL"
        
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        
        cell.textField.text = updatedCardCreateWebhook
        sut.valueDidChange(inFormCell: cell, at: indexPath)

        XCTAssertEqual(sut.attributes.options?.webhooks?.cardCreate, updatedCardCreateWebhook)
    }
    
    func test_valueDidChangeInFormCell_withRow4_shouldSetCardUpdateWebhook() {
        let updatedCardUpdateWebhook = "updated card update URL"
        
        let indexPath = IndexPath(row: 4, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        
        cell.textField.text = updatedCardUpdateWebhook
        sut.valueDidChange(inFormCell: cell, at: indexPath)

        XCTAssertEqual(sut.attributes.options?.webhooks?.cardUpdate, updatedCardUpdateWebhook)
    }
    
    func test_valueDidChangeInFormCell_withRow5_shouldSetShareUrlField() {
        let updatedShareUrlField = titleField
        
        let indexPath = IndexPath(row: 5, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! PopUpButtonCell

        cell.selectedValue = updatedShareUrlField
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.attributes.options?.share?.urlField, updatedShareUrlField?.id)
    }
    
    func test_valueDidChangeInFormCell_withRow6_shouldSetShareTitleField() {
        let updatedShareTitleField = urlField
        
        let indexPath = IndexPath(row: 6, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! PopUpButtonCell

        cell.selectedValue = updatedShareTitleField
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.attributes.options?.share?.urlField, updatedShareTitleField?.id)
    }
}
