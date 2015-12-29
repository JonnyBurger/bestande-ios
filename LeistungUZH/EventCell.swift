//
//  EventCell.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 07.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var timeLabel : UILabel!

    var event : Event? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        titleLabel.text = "\(event!.getTitle()) \(event!.number)"
        timeLabel.text = event!.getSubTitle()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setEvent(event: Event) {
        self.event = event;
    }
    
}
