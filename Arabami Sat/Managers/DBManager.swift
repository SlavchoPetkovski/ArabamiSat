//
//  DBManager.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 10.5.21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import RealmSwift

class DBManager: NSObject {

    static let shared = DBManager()
    
    private func getRealm() -> Realm {
        return Realm.get()
    }
    
    var db: Firestore {
        let localDB = Firestore.firestore()
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        localDB.settings = settings
        
        return localDB
    }

    var listener: ListenerRegistration?

    func addNewCar(car: Car, completion: @escaping (Error?) -> Void) {
        // Also we can use .addDocument(from:) where the imput param (in our case Car) conforms to Encodable
        _ = self.db.collection(FirebaseConstants.carsCollection).addDocument(data: [
            FirebaseConstants.imageRealmId: car.imageRealmId ?? "",
            FirebaseConstants.manufacturerKey: car.manufacturer ?? "",
            FirebaseConstants.modelKey: car.model ?? ""
        ]) { err in
            completion(err)
        }
    }
    
    func getAllCars(completion: @escaping ([Car]?, Error?) -> Void) {
        self.db.collection(FirebaseConstants.carsCollection).getDocuments { (querySnapshot, err) in
            if let err = err {
                completion(nil, err)
            } else {
                let cars = querySnapshot?.documents.compactMap({try? $0.data(as: Car.self)})
                completion(cars, nil)
            }
        }
    }
    
    func saveImageToRealm(with data: Data, id: String) {
        DispatchQueue.main.async {
            let realm = self.getRealm()
            let realmImage = RealmImage()
            realmImage.imageID = id
            realmImage.data = data
            
            try? realm.safeWrite {
                realm.add(realmImage)
            }
        }
    }
    
    func getImageData(id: String) -> Data? {
        let realm = self.getRealm()
        let image = realm.object(ofType: RealmImage.self, forPrimaryKey: id)
        return image?.data
    }
    
    func deleteImageFromRealm(id: String) {
        DispatchQueue.main.async {
            let realm = self.getRealm()
            if let realmImage = realm.object(ofType: RealmImage.self, forPrimaryKey: id) {
                try? realm.safeWrite {
                    realm.delete(realmImage)
                }
            }
        }
    }
    
    func addListener() {
        self.listener = self.db.collection(FirebaseConstants.carsCollection).addSnapshotListener { (querySnapshot, _) in
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            // Deleting the realm image when the car entry (document) is removed
            querySnapshot.documentChanges.forEach { diff in
                if diff.type == .removed,
                   let imgId = diff.document.data()[FirebaseConstants.imageRealmId] as? String {
                    DBManager.shared.deleteImageFromRealm(id: imgId)
                }
            }
            
            let documents = querySnapshot.documents
            let cars = documents.compactMap({try? $0.data(as: Car.self)})
            NotificationCenter.default.post(name: NotificationNames.refreshUInotification, object: cars)
        }
    }
    
    func removeListener() {
        self.listener?.remove()
    }
}
