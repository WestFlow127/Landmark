//
//  LandmarkAuthenticationTests.swift
//  LandmarkTests
//
//  Created by Weston Mitchell on 9/20/23.
//

import XCTest
import FirebaseAuth

@testable import Landmark

class MockAuthService: AuthService
{
    var signInReturnValue: Bool?
    var createUserReturnValue: Bool?
    var signOutReturnValue: Bool = true
    
    var testExpectation: XCTestExpectation?
    
    init() {}
    
    func checkEmailPasswordNotEmpty(
        withEmail email: String,
        password: String,
        completion: ((Any?, Error?) -> Void)? ) -> Bool
    {
        guard !email.isEmpty else {
            completion?(nil, NSError(domain: "FirAuthError", code: AuthErrorCode.missingEmail.rawValue))
            return false
        }
        
        guard !password.isEmpty else {
            completion?(nil, NSError(domain: "FirAuthError", code: AuthErrorCode.wrongPassword.rawValue))
            return false
        }
        return true
    }
    
    func signIn(withEmail email: String, password: String, completion: ((Any?, Error?) -> Void)?)
    {
        guard checkEmailPasswordNotEmpty(withEmail: email, password: password, completion: completion) else {
            testExpectation?.fulfill()
            return
        }

        completion?(signInReturnValue, signInReturnValue == nil ? NSError(domain: "FirAuthError", code: 0) : nil)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.testExpectation?.fulfill()
        }
    }
    
    func createUser(withEmail email: String, password: String, completion: ((Any?, Error?) -> Void)?)
    {
        guard checkEmailPasswordNotEmpty(withEmail: email, password: password, completion: completion) else {
            testExpectation?.fulfill()
            return
        }

        completion?(createUserReturnValue, createUserReturnValue == nil ? NSError(domain: "FirAuthError", code: 0) : nil)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.testExpectation?.fulfill()
        }
    }
    
    func signOut() throws
    {
        if !signOutReturnValue {
            throw AuthErrorCode(.keychainError)
        }
    }
    
    var rememberedEmail: String? = nil
    
    var isSignedIn: Bool = true
}

final class LandmarkAuthenticationTests: XCTestCase {

    var mockAuthService: MockAuthService!
    var loginViewModel: LoginViewModel!

    override func setUpWithError() throws
    {
        mockAuthService = MockAuthService()
        
        loginViewModel = LoginViewModel()
        loginViewModel.authManager = mockAuthService // Inject the mock service.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        loginViewModel = nil
        mockAuthService = nil
    }
    
    func testEmailIsEmpty()
    {
        // Act
        loginViewModel.signIn(email: "", password: "testpassword")
        
        // Assert
        XCTAssertNotNil(loginViewModel.loginError)
        XCTAssertFalse(loginViewModel.signedIn)
    }
    
    func testPasswordIsEmpty()
    {
        // Act
        loginViewModel.signIn(email: "test@email.com", password: "")
        
        // Assert
        XCTAssertNotNil(loginViewModel.loginError)
        XCTAssertFalse(loginViewModel.signedIn)
    }
    
    func testSignInSuccess() {
        // Arrange
        mockAuthService.signInReturnValue = true
        mockAuthService.testExpectation = self.expectation(description: "Sign-in should succeed.")

        // Act
        loginViewModel.signIn(email: "test@email.com", password: "testpassword")
        
        // Assert
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertNil(loginViewModel.loginError)
        XCTAssertTrue(loginViewModel.signedIn)
    }

    func testSignInFailure() {
        // Arrange
        mockAuthService.signInReturnValue = nil
        mockAuthService.testExpectation = self.expectation(description: "Sign-in should fail.")

        // Act
        loginViewModel.signIn(email: "test", password: "testpassword")
        
        // Assert
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertNotNil(loginViewModel.loginError)
        XCTAssertFalse(loginViewModel.signedIn)
    }
    
    func testSignOut() {
        // Arrange
        mockAuthService.signOutReturnValue = false

        // Act
        loginViewModel.logout()
        
        // Assert
        XCTAssertFalse(loginViewModel.signedIn)
    }
    
    // TODO: Create User Tests
}

