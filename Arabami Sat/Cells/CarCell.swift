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
}
