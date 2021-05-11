//
//  DBManager.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 10.5.21.
//

import FirebaseStorage
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
    var taskRef: StorageUploadTask?

    func addNewCar(car: Car, completion: @escaping (Error?) -> Void) {
        // Also we can use .addDocument(from:) where the imput param (in our case Car) conforms to Encodable
        _ = self.db.collection(FirebaseConstants.carsCollection).addDocument(data: [
            FirebaseConstants.imageURL: car.imageURL ?? "",
            FirebaseConstants.imageRealmId: car.imageRealmId ?? "",
            FirebaseConstants.manufacturerKey: car.manufacturer ?? "",
            FirebaseConstants.modelKey: car.model ?? ""
        ]) { err in
            completion(err)
        }
    }

    func startUpload(imageId: String, imageData: Data, completion: @escaping (String?, Error?) -> Void) {
        let uploadRef = Storage.storage().reference(withPath: "cars/\(imageId)")
        let uploadMetadata = StorageMetadata()
        uploadMetadata.contentType = "image/jpeg"

        self.taskRef = uploadRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            print("Upload success: \(String(describing: downloadMetadata))")

            uploadRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error generating URL: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }

                if let url = url {
                    completion(url.absoluteString, nil)
                }
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
    
    func deleteLocalDatabase() {
        DispatchQueue.main.async {
            let realm = self.getRealm()
            try? realm.safeWrite {
                realm.deleteAll()
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
