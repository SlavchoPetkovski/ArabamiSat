//
//  CarDetailsViewController.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 9.5.21.
//

import UIKit

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
        guard let imgId = self.car.imageRealmId,
              let imgData = DBManager.shared.getImageData(id: imgId) else {
            return
        }
        
        self.carImage.image = UIImage(data: imgData)
    }

    private func setupLabels() {
        self.carManufacturerTitleLbl.text = Strings.Manufacturer
        self.carManufacturerLbl.text = self.car.manufacturer
        self.carModelTitleLbl.text = Strings.Model
        self.carModelLbl.text = self.car.model
    }
}
