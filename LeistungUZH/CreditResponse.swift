//
//  CreditResponse.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 18.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation


class CreditResponse {
    var semesters : [Semester] = [];
    var stats : NSDictionary = [:]
    var hasData : Bool = false;
    var noDataReason : NoCreditDataReason = NoCreditDataReason.NOT_TRIED;
    var stack : NSString = "";
    
    init() {
        
    }
}