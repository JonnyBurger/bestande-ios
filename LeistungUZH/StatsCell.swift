//
//  StatsCell.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 10.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit

class StatsCell: UITableViewCell {

    @IBOutlet var ectsPoints : UILabel!
    @IBOutlet var avg : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
