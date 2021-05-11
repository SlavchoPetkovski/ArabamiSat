//
//  RealmImage.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 10.5.21.
//

import RealmSwift

class RealmImage: Object {
    @objc dynamic var imageID: String = ""
    @objc dynamic var documentID: String = ""
    @objc dynamic var data = Data()

    override static func primaryKey() -> String? {
        return "imageID"
    }
}
