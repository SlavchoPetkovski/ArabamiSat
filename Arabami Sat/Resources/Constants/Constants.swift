//
//  Constants.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 8.5.21.
//

import UIKit

struct AppConstants {
    static let loginSegue = "loginSegue"
    static let logoutSegue = "logoutSegue"
    static let detailsSegue = "detailsSegue"
    static let addCarSegue = "addCarSegue"
    static let googleClientID = "485457355655-m6vvhc9088k7j5kh8tn25ha1tiqfrr45.apps.googleusercontent.com"
    static let imageCompression: CGFloat = 0.3
}

struct CellConstants {
    static let carCellIdentifier = "carCell"
}

struct FirebaseConstants {
    static let carsCollection = "cars"
    static let imageURL = "imageURL"
    static let imageRealmId = "imageRealmId"
    static let manufacturerKey = "manufacturer"
    static let modelKey = "model"
}

struct NotificationNames {
    static let refreshUInotification = NSNotification.Name("Notification.refreshUInotification")
    static let uploadFailedNotification = NSNotification.Name("Notification.uploadFailedNotification")
    static let uploadSucceededNotification = NSNotification.Name("Notification.uploadSucceededNotification")
}
