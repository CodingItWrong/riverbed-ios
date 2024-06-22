@testable import Riverbed
import XCTest

final class ChoicesViewControllerTests: XCTestCase {
    
    class TestDelegate: ChoicesDelegate {
        struct Call: Equatable {
            let choices: [Riverbed.Element.Choice]
        }
        
        var calls: [Call] = []
        
        func didUpdate(choices: [Riverbed.Element.Choice]) {
            calls.append(Call(choices: choices))
        }
    }
    
    private var choiceA: Element.Choice!
    private var choiceB: Element.Choice!
    private var choices: [Element.Choice]!

    private var sut: ChoicesViewController!
    private var delegate: TestDelegate!
    
    override func setUp() {
        super.setUp()
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        sut = sb.instantiateViewController(withIdentifier: String(describing: ChoicesViewController.self)) as? ChoicesViewController
        
        choiceA = Element.Choice(id: "choice_a_id", label: "Choice A")
        choiceB = Element.Choice(id: "choice_b_id", label: "Choice B")
        choices = [choiceA, choiceB]
        sut.choices = choices
        
        delegate = TestDelegate()
        sut.delegate = delegate
        
        sut.loadViewIfNeeded()
    }
    
    func test_numberOfRowsInSection_returnsNumberOfChoices() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), choices.count)
    }
    
    func test_cellForRowAt_returnsTextFieldForChoice() {
        let row = 0
        let choice = choices[row]
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.textField.text, choice.label)
    }
    
    func test_moveRowAtTo_callsDelegateWithUpdatedOrder() {
        let fromPath = IndexPath(row: 0, section: 0)
        let toPath = IndexPath(row: 1, section: 0)
        let reversedChoices: [Element.Choice] = [choiceB, choiceA]
        
        sut.tableView(sut.tableView, moveRowAt: fromPath, to: toPath)
        
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(choices: reversedChoices)])
    }
    
    func test_commitForRowAt_withDelete_deletesRowAndCallsDelegate() {
        let choicesWithADeleted: [Element.Choice] = [choiceB]
        
        sut.tableView(sut.tableView, commit: .delete, forRowAt: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(choices: choicesWithADeleted)])
        
        // TODO: how to test that row actually deleted? Maybe rely on manual testing for that
    }
    
    func test_addChoice_callsDelegateWithNewChoice() {
        sut.addChoice(nil)
        
        XCTAssertEqual(delegate.calls.count, 1)
        let updatedChoices = (delegate.calls.first?.choices)!
        XCTAssertEqual(updatedChoices.count, choices.count + 1)
        let newChoice = updatedChoices.last
        XCTAssertEqual(newChoice?.label, nil)
    }
    
    func test_valueDidChangeInFormCellAt_updatesLabelForChoiceAndCallsDelegate() {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        let updatedLabel = "UpdatedLabel"
        let choicesWithLabelUpdated: [Element.Choice] = [
            choiceA,
            Element.Choice(id: choiceB.id, label: updatedLabel)
        ]
        
        cell.textField.text = updatedLabel
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.choices[1].label, updatedLabel)
        XCTAssertEqual(delegate.calls, [TestDelegate.Call(choices: choicesWithLabelUpdated)])
    }
}
