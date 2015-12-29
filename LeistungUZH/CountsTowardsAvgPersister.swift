//
//  CountsTowardsAvgPersister.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 06.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation


class CountsTowardsAvgPersister {
    static let sharedInstance = CountsTowardsAvgPersister();
    let defaults = NSUserDefaults.standardUserDefaults()
    func set(module: Credit, counts: Bool) {
        defaults.setBool(counts, forKey: "counts-" + module.module);
    }
    
    func get(module: Credit) -> Bool {
        if (!canCount(module)) {
            return false;
        }
        if defaults.objectForKey("counts-" + module.module) != nil {
            return defaults.boolForKey("counts-" + module.module)
        }
        return defaultShouldCount(module);
    }
    
    func defaultShouldCount(module: Credit) -> Bool {
        if (!canCount(module)) {
           return false;
        }
        if module.status == .FAILED {
            return false;
        }
        let grade = Double(module.grade);
        if grade != nil {
            if grade >= 1 && grade <= 6 {
                return true;
            }
            return false;
        }
        return false;
    }
    
    func canCount(module: Credit) -> Bool {
        if module.status == .DESELECTED {
            return false;
        }
        if module.status == .BOOKED {
            return false;
        }
        let grade = Double(module.grade);
        if grade != nil && grade >= 1 && grade <= 6 {
            return true;
        }
        if module.grade == "BEST" {
            return true;
        }
        if module.grade == "N.BE" {
            return true;
        }
        if module.grade == "N. BE" {
            return true;
        }
        return false;
    }
}