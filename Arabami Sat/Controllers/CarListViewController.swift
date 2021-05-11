//
//  CarListViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 8.5.21.
//

import UIKit
import FBSDKLoginKit

class CarListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.tableFooterView = UIView()
        }
    }

    private var cars = [Car]()
    private var carsChangedNotification: NSObjectProtocol?
    let reachability = try? Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupNotifications()
        DBManager.shared.addListener()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)),
                                               name: .reachabilityChanged, object: self.reachability)

        do {
            try self.reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: self.reachability)
    }

    deinit {
        DBManager.shared.removeListener()
        NotificationCenter.default.removeObserver(self.carsChangedNotification as Any)
    }

    private func setupNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = User.shared.username ?? Strings.UnknownUser
    }

    private func setupNotifications() {
        self.carsChangedNotification = NotificationCenter.default.addObserver(
            forName: NotificationNames.refreshUInotification,
            object: nil, queue: .main) { [weak self] notification in
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

    // MARK: - Notifications
    @objc func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else {
            return
        }

        switch reachability.connection {
        case .wifi, .cellular:
            DBManager.shared.syncIfNeeded()
        case .unavailable:
            break
        }
    }

    @IBAction func logout(_ sender: Any) {
        AuthenticationManager.logout()
        DBManager.shared.deleteLocalDatabase()
        guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        appDel.logoutIfNeeded()
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
        cell.setup(car: car)

        return cell
    }
}
