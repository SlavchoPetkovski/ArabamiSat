//
//  User.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 9.5.21.
//

import UIKit

final class User {
    static let shared = User()

    let userDefaults: UserDefaults

    /// For testability, simply inject a different `UserDefaults`.
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func removeUser() {
        self.userDefaults.removeObject(forKey: "username")
        self.userDefaults.synchronize()
    }

    var username: String? {
        get {
            return self.userDefaults.string(forKey: "username")
        }

        set {
            self.userDefaults.set(newValue, forKey: "username")
        }
    }
}
