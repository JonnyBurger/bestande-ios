//
//  Semester.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 11.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation

class Semester {
    var semester : String = "FS00"
    var credits : [Credit] = []
    
    init(obj: NSDictionary) {
        self.semester = obj["semester"] as! String
        let _credits = obj["credits"] as! NSArray as! [NSDictionary]
        self.credits = _credits.map({ (obj: NSDictionary) -> Credit in
            Credit(obj: obj)
        })
    }
}