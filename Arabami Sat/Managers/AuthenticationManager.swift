//
//  AuthenticationManager.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 8.5.21.
//

import Foundation
import FBSDKLoginKit
import GoogleSignIn
import FirebaseAuth

enum AuthType {
    case facebook
    case google
}

enum LoginResult {
    case success
    case cancelled
    case error
    case none
}

class AuthenticationManager: NSObject {
    var handler: ((AuthDataResult?, Error?) -> Void)?
    private var type: AuthType?
    private var viewController: UIViewController?
    
    let fbLoginManager: LoginManager
    let googleLoginManager: GIDSignIn
    weak var delegate: GIDSignInDelegate?
    var loginResult: LoginResult = .none

    init(type: AuthType, viewController: UIViewController, fbLoginManager: LoginManager = LoginManager(), googleLoginManager: GIDSignIn = GIDSignIn.sharedInstance(), delegate: GIDSignInDelegate? = nil) {
        self.type = type
        self.viewController = viewController
        self.fbLoginManager = fbLoginManager
        self.googleLoginManager = googleLoginManager
        self.delegate = delegate
        super.init()
    }

    static var isUserAuthenticated: Bool {
        return Auth.auth().currentUser != nil
    }

    func signIn() {
        switch self.type {
        case .facebook:
            self.signInWithFacebook()
        case .google:
            self.signInWithGoogle()
        default:
            break
        }
    }

    class func logout() {
        User.shared.removeUser()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    private func signInWithFacebook() {
        self.fbLoginManager.logIn(permissions: ["email", "public_profile"], from: self.viewController) { (result, error) in
            // Check for error
            guard error == nil else {
                // Error occurred
                self.loginResult = .error
                self.handler?(nil, error)
                return
            }

            // Check for cancel
            guard let result = result, !result.isCancelled else {
                print("User cancelled login")
                self.loginResult = .cancelled
                self.handler?(nil, error)
                return
            }

            // Successfully logged in
            self.loginResult = .success
            guard let accessToken = AccessToken.current else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential, completion: self.handler)
        }
    }

    private func signInWithGoogle() {
        self.googleLoginManager.clientID = AppConstants.googleClientID
        self.googleLoginManager.delegate = self.delegate
        self.googleLoginManager.presentingViewController = self.viewController

        if self.googleLoginManager.hasPreviousSignIn() {
            self.googleLoginManager.restorePreviousSignIn()
        } else {
            self.googleLoginManager.signIn()
        }
    }
}

extension AuthenticationManager: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.handler?(nil, error)
            return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential, completion: self.handler)
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        self.handler?(nil, error)
    }
}
