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

class AuthenticationManager: NSObject {
    var handler: ((AuthDataResult?, Error?) -> Void)?
    private var type: AuthType?
    private var viewController: UIViewController?

    init(type: AuthType, viewController: UIViewController) {
        self.type = type
        self.viewController = viewController
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
        LoginManager().logIn(permissions: [], from: self.viewController) { (result, error) in
            // Check for error
            guard error == nil else {
                // Error occurred
                self.handler?(nil, error)
                return
            }

            // Check for cancel
            guard let result = result, !result.isCancelled else {
                print("User cancelled login")
                self.handler?(nil, error)
                return
            }

            // Successfully logged in
            guard let accessToken = AccessToken.current else { return }
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential, completion: self.handler)
        }
    }

    private func signInWithGoogle() {
        GIDSignIn.sharedInstance().clientID = AppConstants.googleClientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self.viewController
        GIDSignIn.sharedInstance().signIn()
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
