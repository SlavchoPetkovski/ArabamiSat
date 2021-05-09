//
//  CarListViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 8.5.21.
//

import UIKit
import FBSDKLoginKit

class CarListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = User.shared.username ?? Strings.UnknownUser
    }

    @IBAction func logout(_ sender: Any) {
        AuthenticationManager.logout()
        self.performSegue(withIdentifier: AppConstants.logoutSegue, sender: self)
    }
}
