//
//  Arabami_SatTests.swift
//  Arabami SatTests
//
//  Created by Slavcho Petkovski on 11.5.21.
//

import XCTest
import FBSDKLoginKit
@testable import Arabami_Sat

class ArabamiSatTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFBLoginSuccess() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let controller = UIViewController()
        let token = AccessToken(tokenString: "", permissions: [], declinedPermissions: [], expiredPermissions: [], appID: "", userID: "", expirationDate: Date(), refreshDate: Date(), dataAccessExpirationDate: Date())
        let result = LoginManagerLoginResult(token: token, authenticationToken: nil, isCancelled: false, grantedPermissions: Set(), declinedPermissions: Set())
        let loginManagerMock = LoginManagerMock(result: result, error: nil)
        let authManager = AuthenticationManager(type: .facebook, viewController: controller, loginManager: loginManagerMock)
        
        XCTAssertEqual(authManager.loginResult, .none)
        authManager.signIn()
        XCTAssertEqual(authManager.loginResult, .success)
    }
    
    func testFBLoginCancel() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let controller = UIViewController()
        let result = LoginManagerLoginResult(token: nil, authenticationToken: nil, isCancelled: true, grantedPermissions: Set(), declinedPermissions: Set())
        let loginManagerMock = LoginManagerMock(result: result, error: nil)
        let authManager = AuthenticationManager(type: .facebook, viewController: controller, loginManager: loginManagerMock)
        
        XCTAssertEqual(authManager.loginResult, .none)
        authManager.signIn()
        XCTAssertEqual(authManager.loginResult, .cancelled)
    }
    
    func testFBLoginError() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let controller = UIViewController()
        let result = LoginManagerLoginResult(token: nil, authenticationToken: nil, isCancelled: false, grantedPermissions: Set(), declinedPermissions: Set())
        let loginManagerMock = LoginManagerMock(result: result, error: NSError(domain: "", code: 500, userInfo: nil))
        let authManager = AuthenticationManager(type: .facebook, viewController: controller, loginManager: loginManagerMock)
        
        XCTAssertEqual(authManager.loginResult, .none)
        authManager.signIn()
        XCTAssertEqual(authManager.loginResult, .error)
    }
}
