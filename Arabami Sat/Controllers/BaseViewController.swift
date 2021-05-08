//
//  BaseViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 8.5.21.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func showAlert(with title: String, message: String, completion: ((String) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: Strings.OKButton, style: .default, handler: nil)

        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
