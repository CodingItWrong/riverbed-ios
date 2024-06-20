@testable import Riverbed
import XCTest

class TestSignInDelegate: SignInDelegate {
    var tokenResponses: [TokenResponse] = []
    
    func didReceive(tokenResponse: Riverbed.TokenResponse) {
        tokenResponses.append(tokenResponse)
    }
}

final class SignInViewControllerTests: XCTestCase {
    
    private var sut: SignInViewController!
    private var tokenStore: MockTokenStore!
    private var signInDelegate: TestSignInDelegate!
    
    override func setUp() {
        super.setUp()
        
        signInDelegate = TestSignInDelegate()
        tokenStore = MockTokenStore()
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        sut = sb.instantiateViewController(withIdentifier: String(describing: SignInViewController.self)) as? SignInViewController
        sut.tokenStore = tokenStore
        sut.delegate = signInDelegate
        
        sut.loadViewIfNeeded()
    }

    func test_signIn_sendsEmailAndPassword() {
        let email = "testemail@example.calm"
        let password = "fake_password"
        sut.emailField.text = email
        sut.passwordField.text = password
        
        sut.signIn()
        
        XCTAssertEqual(tokenStore.createCalls.count, 1)
        XCTAssertEqual(tokenStore.createCalls.first?.email, email)
        XCTAssertEqual(tokenStore.createCalls.first?.password, password)
    }
    
    func test_signIn_whenSuccess_callsDidReceiveTokenResponse() {
        tokenStore.createResult = .success(TokenResponse(accessToken: "fake_access_token",
                                                         tokenType: "fake_token_type",
                                                         createdAt: 1718885326,
                                                         userId: 1))
        
        sut.signIn()
        
        XCTAssertEqual(signInDelegate.tokenResponses.count, 1)
    }
    
    func test_signIn_whenApiError_displaysMessage() {
        tokenStore.createResult = .failure(APIError.serverError(httpStatus: 400, body: "Unauthorized"))
        
        sut.signIn()
        
        XCTAssertEqual(signInDelegate.tokenResponses.count, 0)
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "Incorrect username or password.")
    }
    
    func test_signIn_whenUnknownError_displaysMessage() {
        tokenStore.createResult = .failure(APIError.serverError(httpStatus: 500, body: "Server error"))
        
        sut.signIn()
        
        XCTAssertEqual(signInDelegate.tokenResponses.count, 0)
        XCTAssertEqual(sut.errorLabel.isHidden, false)
        XCTAssertEqual(sut.errorLabel.text, "An error occurred while attempting to sign in. Please try again.")
    }
}
