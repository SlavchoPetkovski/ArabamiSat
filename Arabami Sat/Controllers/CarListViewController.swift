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
    private var carsChangedNotification: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = User.shared.username ?? Strings.UnknownUser
        self.tableView.tableFooterView = UIView()
        DBManager.shared.addListener()
        self.setupNotifications()
        
        DBManager.shared.getAllCars(completion: { cars, error in
            guard error == nil, let cars = cars else {
                return
            }
            
            self.cars = cars
            self.tableView.reloadData()
        })
    }
    
    deinit {
        DBManager.shared.removeListener()
        NotificationCenter.default.removeObserver(self.carsChangedNotification as Any)
    }
    
    private func setupNotifications() {
        self.carsChangedNotification = NotificationCenter.default.addObserver(forName: NotificationNames.refreshUInotification, object: nil, queue: .main) { [weak self] notification in
            guard let strongSelf = self else {
                return
            }
            
            guard let cars = notification.object as? [Car] else {
                return
            }
            
            strongSelf.cars = cars
            strongSelf.tableView.reloadData()
        }
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
        if let imgId = car.imageRealmId,
           let imageData = DBManager.shared.getImageData(id: imgId) {
            cell.carImage.image = UIImage(data: imageData)
        }
        
        cell.carManufacturerLbl.text = car.manufacturer
        cell.carModelLbl.text = car.model

        return cell
    }
}
