//
//  AddCarViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 9.5.21.
//

import UIKit
import FirebaseCrashlytics

class AddCarViewController: BaseViewController {
    enum ValidationError {
        case noImageSelected
        case noManufacturer
        case noModel
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var openGalleryBtn: UIButton!
    @IBOutlet weak var manufacturerTF: UITextField!
    @IBOutlet weak var modelTF: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupViews()
        self.setupButton()
        self.setupTextFields()
        self.registerForNotifications()

        Crashlytics.crashlytics().setCustomValue("will add new car", forKey: "addCar")
        Crashlytics.crashlytics().log("custom message")
    }

    private func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    private func setupButton() {
        self.openGalleryBtn.setTitle(Strings.SelectImage, for: .normal)
    }

    private func setupTextFields() {
        self.manufacturerTF.placeholder = Strings.Manufacturer
        self.modelTF.placeholder = Strings.Model
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    private func validateCar() -> ValidationError? {
        guard self.carImageView.image != nil else {
            return .noImageSelected
        }

        guard let text = self.manufacturerTF.text,
              !text.isEmpty else {
            return .noManufacturer
        }

        guard let text = self.modelTF.text,
              !text.isEmpty else {
            return .noModel
        }

        return nil
    }

    // MARK: Notifications methods
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let info = (notification as NSNotification).userInfo,
            let val = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        var kbRect = val.cgRectValue
        kbRect = self.view.convert(kbRect, from: nil)

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbRect.size.height, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var aRect = self.view.frame
        aRect.size.height -= kbRect.size.height

        let scrollPointY = kbRect.size.height - self.view.frame.size.height - self.modelTF.frame.origin.y
            + self.modelTF.frame.size.height - 20
        if !aRect.contains(CGPoint(x: self.modelTF.frame.origin.x, y: self.modelTF.frame.origin.y)) {
            let scrollPoint = CGPoint(x: 0.0, y: scrollPointY)
            self.scrollView.setContentOffset(scrollPoint, animated: true)
        }

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func hideKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // IBActions
    @IBAction func pickImageFromGallery(_ sender: UIButton) {
        DispatchQueue.main.async {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary

            self.present(picker, animated: true)
        }
    }

    @IBAction func saveCar(_ sender: Any) {
        guard let error = self.validateCar() else {
            guard let image = self.carImageView.image,
                  let imageData = image.jpegData(compressionQuality: AppConstants.imageCompression) else {
                self.showAlert(with: Strings.Error, message: Strings.NoImageSelected)
                return
            }

            let id = UUID().uuidString
            if Commons.isConnectedToNetwork() {
                self.activityIndicator.startAnimating()
                // Uploading the image to storage
                DBManager.shared.startUpload(imageId: id, imageData: imageData) { [weak self] urlStr, error in
                    self?.activityIndicator.stopAnimating()

                    if let error = error {
                        self?.showAlert(with: Strings.Error, message: error.localizedDescription)
                        return
                    }

                    self?.addNewCar(with: id, urlString: urlStr!)
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                // Saving the image in Realm when offline
                DBManager.shared.saveImageToRealm(with: imageData, id: id)
                self.addNewCar(with: id)
                self.navigationController?.popViewController(animated: true)
            }

            return
        }

        switch error {
        case .noImageSelected:
            self.showAlert(with: Strings.Error, message: Strings.NoImageSelected)
        case .noManufacturer:
            self.showAlert(with: Strings.Error, message: Strings.NoManufacturer)
        case .noModel:
            self.showAlert(with: Strings.Error, message: Strings.NoModel)
        }
    }

    private func addNewCar(with id: String, urlString: String? = nil) {
        let manufacturer = self.manufacturerTF.text
        let model = self.modelTF.text
        let newCar = Car(imageURL: urlString, imageRealmId: id, manufacturer: manufacturer, model: model)
        DBManager.shared.addNewCar(car: newCar) { [weak self] docId, error in
            guard let err = error else {
                if urlString == nil, let docId = docId {
                    DBManager.shared.updateRealmImage(with: docId, id: id)
                }

                return
            }

            self?.showAlert(with: Strings.Error, message: err.localizedDescription)
        }
    }
}

extension AddCarViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.manufacturerTF {
            self.modelTF.becomeFirstResponder()
        } else {
            self.modelTF.resignFirstResponder()
        }

        return true
    }
}

extension AddCarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.carImageView.image = image
        }

        self.dismiss(animated: true, completion: nil)
    }
}
