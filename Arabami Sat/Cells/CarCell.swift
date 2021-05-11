//
//  CarCell.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 9.5.21.
//

import UIKit
import SDWebImage

class CarCell: UITableViewCell {

    @IBOutlet weak var carImage: UIImageView!
    @IBOutlet weak var carManufacturerTitleLbl: UILabel!
    @IBOutlet weak var carManufacturerLbl: UILabel!
    @IBOutlet weak var carModelTitleLbl: UILabel!
    @IBOutlet weak var carModelLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.carManufacturerTitleLbl.text = Strings.Manufacturer + ":"
        self.carModelTitleLbl.text = Strings.Model + ":"
    }

    func setup(car: Car) {
        if let imageURL = car.imageURL, !imageURL.isEmpty {
            self.carImage.sd_setImage(with: URL(string: imageURL),
                                      placeholderImage: nil, options: .highPriority, context: nil)
        } else {
            if let imgId = car.imageRealmId,
               let imageData = DBManager.shared.getImageData(id: imgId) {
                self.carImage.image = UIImage(data: imageData)
            }
        }

        self.carManufacturerLbl.text = car.manufacturer
        self.carModelLbl.text = car.model
    }
}
