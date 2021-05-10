//
//  AppDelegate.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 7.5.21.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        var rootVC: UIViewController!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        FirebaseApp.configure()
        self.realmMigrate()

        if AuthenticationManager.isUserAuthenticated {
            rootVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: CarListViewController.self))
        } else {
            rootVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: LoginViewController.self))
        }

        let navigationController = UINavigationController(rootViewController: rootVC)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()

        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    func realmMigrate() {
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 1, migrationBlock: { (_, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
            }
        })
    }

    func logoutIfNeeded() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(
            withIdentifier: String(describing: LoginViewController.self))
        if let navigationController = self.window?.rootViewController as? UINavigationController {
            navigationController.pushViewController(loginViewController, animated: true)
            navigationController.viewControllers = [loginViewController]
            navigationController.dismiss(animated: true, completion: nil)
        }
    }
}
