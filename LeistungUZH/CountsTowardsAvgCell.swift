//
//  CountsTowardsAverageCell.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 07.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit

class CountsTowardsAvgCell : UITableViewCell {
    @IBOutlet var countsTowardsAvgSwitch : UISwitch!
    @IBOutlet var label : UILabel!
    
    var credit : Credit?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        countsTowardsAvgSwitch.addTarget(self, action: "updateDefaultForSwitch", forControlEvents: .ValueChanged);
        
    }
    
    
    func updateCountsSwitch(anim: Bool) {
        self.countsTowardsAvgSwitch.setOn(CountsTowardsAvgPersister.sharedInstance.get(credit!), animated: anim)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCountsSwitch(false);
    }
    
    func switched() {
        CountsTowardsAvgPersister.sharedInstance.set(credit!, counts: !self.countsTowardsAvgSwitch.on);
    }
    
    func updateDefaultForSwitch() {
        CountsTowardsAvgPersister.sharedInstance.set(credit!, counts: countsTowardsAvgSwitch.on);
    }
    
    func setCellAsInactive() {
        countsTowardsAvgSwitch.enabled = false;
        label.textColor = UIColor.grayColor();
    }
    
}
