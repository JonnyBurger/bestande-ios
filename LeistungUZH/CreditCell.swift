//
//  CreditCEll.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 09.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit

class CreditCell: UITableViewCell {

    @IBOutlet var mainTitle : UILabel!
    @IBOutlet var subTitle : UILabel!
    @IBOutlet var ects : UILabel!
    @IBOutlet var grade : UILabel!
    @IBOutlet var color : UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        color.layer.cornerRadius = 7
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
