//
//  CarDetailsViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 9.5.21.
//

import UIKit
import SDWebImage

class CarDetailsViewController: UIViewController {

    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carManufacturerTitleLbl: UILabel!
    @IBOutlet weak var carManufacturerLbl: UILabel!
    @IBOutlet weak var carModelTitleLbl: UILabel!
    @IBOutlet weak var carModelLbl: UILabel!

    let car: Car

    init?(coder: NSCoder, car: Car) {
        self.car = car
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadImage()
        self.setupLabels()
    }

    private func loadImage() {
        if let imageURL = self.car.imageURL {
            self.carImage.sd_setImage(with: URL(string: imageURL), completed: nil)
        } else if let imgId = self.car.imageRealmId,
                  let localImageData = DBManager.shared.getImageData(id: imgId) {
            self.carImage.image = UIImage(data: localImageData)
        }
    }

    private func setupLabels() {
        self.carManufacturerTitleLbl.text = Strings.Manufacturer
        self.carManufacturerLbl.text = self.car.manufacturer
        self.carModelTitleLbl.text = Strings.Model
        self.carModelLbl.text = self.car.model
    }
}
