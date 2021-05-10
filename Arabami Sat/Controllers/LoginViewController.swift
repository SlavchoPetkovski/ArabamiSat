//
//  LoginViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 7.5.21.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: BaseViewController {

    @IBOutlet weak var fbLoginBtn: FBButton!
    @IBOutlet weak var googleLoginBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    func setupButtons() {
        self.fbLoginBtn.setTitle(Strings.LoginButtonTitle, for: .normal)
        self.googleLoginBtn.setTitle(Strings.GoogleButtonTitle, for: .normal)
    }

    // IBActions
    @IBAction func fbLoginTapped(_ sender: UIButton) {
        self.loginTapped(type: .facebook)
    }

    @IBAction func googleLoginTapped(_ sender: Any?) {
        self.loginTapped(type: .google)
    }

    private func loginTapped(type: AuthType) {
        let authManager  = AuthenticationManager(type: type, viewController: self)
        authManager.handler = { [weak self] auth, error in
            if let error = error {
                self?.showAlert(with: Strings.Error, message: error.localizedDescription, completion: nil)
                return
            }

            guard let auth = auth else {
                return
            }

            let username = auth.additionalUserInfo?.profile?["name"] as? String
            User.shared.username = username
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: AppConstants.loginSegue, sender: username)
            }
        }

        authManager.signIn()
    }
}
