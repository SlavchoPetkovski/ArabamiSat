//
//  AddCarViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 9.5.21.
//

import UIKit

protocol AddCarDelegate: AnyObject {
    func addCar(car: Car)
}

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

    weak var delegate: AddCarDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupViews()
        self.setupButton()
        self.setupTextFields()
        self.registerForNotifications()
    }

    func setupViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    func setupButton() {
        self.openGalleryBtn.setTitle(Strings.SelectImage, for: .normal)
    }

    func setupTextFields() {
        self.manufacturerTF.placeholder = Strings.Manufacturer
        self.modelTF.placeholder = Strings.Model
    }

    func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    func validateCar() -> ValidationError? {
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
    @objc func keyboardWillShow(_ notification: Notification) {
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

    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    // IBActions
    @IBAction func pickImageFromGallery(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        if let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            picker.mediaTypes = mediaTypes
        }

        self.present(picker, animated: true)
    }

    @IBAction func saveCar(_ sender: Any) {
        guard let error = self.validateCar() else {
            let manufacturer = self.manufacturerTF.text
            let model = self.manufacturerTF.text

            self.showAlert(with: Strings.Success, message: Strings.CarAdded) { _ in
                self.navigationController?.popViewController(animated: true)
                let newCar = Car(manufacturer: manufacturer, model: model)
                self.delegate?.addCar(car: newCar)
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
