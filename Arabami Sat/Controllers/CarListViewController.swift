//
//  CarListViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 8.5.21.
//

import UIKit
import FBSDKLoginKit

class CarListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    var cars = [Car]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = User.shared.username ?? Strings.UnknownUser
        self.tableView.tableFooterView = UIView()
    }

    @IBAction func logout(_ sender: Any) {
        AuthenticationManager.logout()
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        appDel.logoutIfNeeded()
    }

    @IBAction func addCar(_ sender: Any) {
        self.performSegue(withIdentifier: AppConstants.addCarSegue, sender: self)
    }

    @IBSegueAction func makeCarDetailsViewController(_ coder: NSCoder) -> CarDetailsViewController? {
        guard let selectedRow = self.tableView.indexPathForSelectedRow?.row else {
            return nil
        }

        let car = self.cars[selectedRow]
        return CarDetailsViewController(coder: coder, car: car)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppConstants.addCarSegue,
           let addVC = segue.destination as? AddCarViewController {
            addVC.delegate = self
        }
    }
}

extension CarListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cars.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: CellConstants.carCellIdentifier) as? CarCell else {
            fatalError() // should never happen
        }

        let car = self.cars[indexPath.row]
        cell.carManufacturerLbl.text = car.manufacturer
        cell.carModelLbl.text = car.model

        return cell
    }
}

extension CarListViewController: AddCarDelegate {
    func addCar(car: Car) {
        print("car added delegate")
    }
}
