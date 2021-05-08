//
//  CarListViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 8.5.21.
//

import UIKit
import FBSDKLoginKit

class CarListViewController: UIViewController {

    var fullName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

        let fullNameStr = self.fullName != nil ? self.fullName : Strings.UnknownUser
        self.navigationItem.title = fullNameStr
    }

    @IBAction func logout(_ sender: Any) {
        AuthenticationManager.logout()
    }
}
