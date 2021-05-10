//
//  CarCell.swift
//  Arabami Sat
//
//  Created by Slavcho Petkovski on 9.5.21.
//

import UIKit

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
        if let imgId = car.imageRealmId {
            if let image = DBManager.shared.nsCache.object(forKey: imgId as NSString) {
                self.carImage.image = image
            } else if let imageData = DBManager.shared.getImageData(id: imgId) {
                self.carImage.image = UIImage(data: imageData)
            }
        }
        
        self.carManufacturerLbl.text = car.manufacturer
        self.carModelLbl.text = car.model
    }
}
