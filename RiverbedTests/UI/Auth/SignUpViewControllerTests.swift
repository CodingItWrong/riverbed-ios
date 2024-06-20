@testable import Riverbed
import XCTest
import ViewControllerPresentationSpy

final class SignUpViewControllerTests: XCTestCase {
    
    private var sut: SignUpViewController!
    private var userStore: MockUserStore!
    private var alertVerifier: AlertVerifier!
    
    @MainActor override func setUp() {
        super.setUp()

        alertVerifier = AlertVerifier()

        let sb = UIStoryboard(name: "Main", bundle: nil)
        sut = sb.instantiateViewController(withIdentifier: String(describing: SignUpViewController.self)) as? SignUpViewController
        sut.attributes.email = "example@example.com"
        let password = "password"
        sut.attributes.password = password
        sut.passwordConfirmation = password
        sut.attributes.allowEmails = true
        
        userStore = MockUserStore()
        sut.userStore = userStore
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        userStore = nil
        alertVerifier = nil
        super.tearDown()
    }
    
    func test_numberOfRowsInSection_returns999() {
        XCTAssertEqual(sut.tableView(sut.tableView, numberOfRowsInSection: 0), 5)
    }
    
    func test_cellForRowAt_row0_returnsEmail() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Email Address")
        XCTAssertEqual(cell.textField.keyboardType, .emailAddress)
        XCTAssertEqual(cell.textField.textContentType, .username)
    }
    
    func test_cellForRowAt_row1_returnsPassword() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Password")
        XCTAssertEqual(cell.textField.isSecureTextEntry, true)
        XCTAssertEqual(cell.textField.textContentType, .newPassword)
    }
    
    func test_cellForRowAt_row2_returnsPasswordConfirmation() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! TextFieldCell
        
        XCTAssertEqual(cell.label.text, "Confirm Password")
        XCTAssertEqual(cell.textField.isSecureTextEntry, true)
        XCTAssertEqual(cell.textField.textContentType, .newPassword)
    }
    
    func test_cellForRowAt_row3_returnsAllowEmails() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 3, section: 0)) as! PopUpButtonCell
        
        XCTAssertEqual(cell.label.text, "Allow important emails about your account?")
        XCTAssertEqual(cell.selectedValue as! Bool?, true)
        XCTAssertEqual(cell.popUpButton.menu?.children.count, 3)
        XCTAssertEqual(cell.popUpButton.menu?.children[0].title, "(choose)")
        XCTAssertEqual(cell.popUpButton.menu?.children[1].title, "No")
        XCTAssertEqual(cell.popUpButton.menu?.children[2].title, "Yes")
    }
    
    func test_cellForRowAt_row4_returnsSignupButton() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 4, section: 0)) as! ButtonCell
        
        XCTAssertNil(cell.label.text)
        XCTAssertEqual(cell.button.title(for: .normal), "Sign up")
    }
    
    func test_valueDidChangeIn_row0_setsEmail() {
        sut.attributes.email = "original email"
        let updatedEmail = "updated email"
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        
        cell.textField.text = updatedEmail
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.attributes.email, updatedEmail)
    }
    
    func test_valueDidChangeIn_row1_setsPassword() {
        sut.attributes.password = "original password"
        let updatedPassword = "updated password"
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        
        cell.textField.text = updatedPassword
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.attributes.password, updatedPassword)
    }
    
    func test_valueDidChangeIn_row2_setsPasswordConfirmation() {
        sut.passwordConfirmation = "original password"
        let updatedPassword = "updated password"
        let indexPath = IndexPath(row: 2, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! TextFieldCell
        
        cell.textField.text = updatedPassword
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.passwordConfirmation, updatedPassword)
    }
    
    func test_valueDidChangeIn_row3_setsAllowEmails() {
        sut.attributes.allowEmails = nil
        let indexPath = IndexPath(row: 3, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath) as! PopUpButtonCell
        
        cell.selectedValue = true
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.attributes.allowEmails, true)
    }
    
    // TODO: maybe move this to textFieldDidChangeSelection to match sign in
    func test_valueDidChangeIn_errorShown_hidesError() {
        sut.displayError("Fake error")
        
        XCTAssertEqual(sut.errorLabel.isHidden, false) // precondition
        
        let indexPath = IndexPath(row: 0, section: 0)
        let cell = sut.tableView(sut.tableView, cellForRowAt: indexPath)
        sut.valueDidChange(inFormCell: cell, at: indexPath)
        
        XCTAssertEqual(sut.errorLabel.isHidden, true)
    }
    
    func pressSignUpButton() {
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 4, section: 0))
        sut.didPressButton(inFormCell: cell)
    }

    func test_didPressButton_whenEmailBlank_showsError() {
        sut.attributes.email = ""
        
        pressSignUpButton()
        
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "Email is required")
    }
    
    func test_didPressButton_whenEmailInvalid_showsError() {
        sut.attributes.email = "not.a.real&email.address"
        
        pressSignUpButton()
        
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "Email does not appear to be a valid email address")
    }
    
    func test_didPressButton_whenPasswordBlank_showsError() {
        sut.attributes.password = ""
        
        pressSignUpButton()
        
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "Password is required")
    }
    
    func test_didPressButton_whenPasswordShort_showsError() {
        sut.attributes.password = "1234567"
        
        pressSignUpButton()
        
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "Password must be at least 8 characters")
    }
    
    func test_didPressButton_whenPasswordConfirmationDoesNotMatch_showsError() {
        sut.attributes.password = "correct password"
        sut.passwordConfirmation = "incorrect password"
        
        pressSignUpButton()
        
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "Passwords do not match")
    }
    
    func test_didPressButton_whenAllowEmailsBlank_showsError() {
        sut.attributes.allowEmails = nil
        
        pressSignUpButton()
        
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "Please choose whether or not to allow emails")
    }
    
    func test_didPressButton_whenFormValidAndCreateFails_showsError() {
        userStore.createResult = .failure(APIError.unknownError)
        
        pressSignUpButton()
        
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "An error occurred while creating your account. Please try again.")
    }
    
    @MainActor func test_didPressButton_whenFormValidAndCreateSucceeds_showsAlert() {
        userStore.createResult = .success(())
        
        pressSignUpButton()
        
        let message = "Congratulations, your Riverbed account has been created! " +
                      "You can now log in with the username and password you provided."
        alertVerifier.verify(title: "Account Created",
                             message: message,
                             animated: true,
                             actions: [.default("OK")])
    }
}
