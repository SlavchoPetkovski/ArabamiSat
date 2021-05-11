//
//  GoogleLoginDelegateMock.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 11.5.21.
//

import GoogleSignIn
import XCTest

class GoogleLoginDelegateMock: NSObject, GIDSignInDelegate {
    let expectation: XCTestExpectation
    let error: NSError?

    init(expectation: XCTestExpectation, error: NSError? = nil) {
        self.expectation = expectation
        self.error = error
    }
    var hasError = false

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if self.error != nil {
            self.hasError = true
            self.expectation.fulfill()
            return
        }

        self.hasError = false
        self.expectation.fulfill()
    }
}
