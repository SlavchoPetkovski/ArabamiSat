//
//  LoginManagerMock.swift
//  Arabami SatTests
//
//  Created by Slavcho Petkovski on 11.5.21.
//

import FBSDKLoginKit

class FBLoginManagerMock: LoginManager {
    let result: LoginManagerLoginResult?
    let error: NSError?
    
    init(result: LoginManagerLoginResult, error: NSError?) {
        self.result = result
        self.error = error
    }
    
    override func logIn(permissions: [String], from fromViewController: UIViewController?, handler: LoginManagerLoginResultBlock? = nil) {
        if let handler = handler {
            handler(self.result, self.error)
        }
    }
}
