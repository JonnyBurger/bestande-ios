//
//  Credit.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 11.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation

class Credit {
    var name : String = ""
    var short_name : String = ""
    var credits_worth : Float = 0.0
    var credits_received : Float = 0.0
    var link : String = ""
    var module : String = ""
    var status : PassStatus = .UNKNOWN
    var grade : String = ""
    
    init(obj: NSDictionary) {
        self.name = obj["name"] as! String
        self.short_name = obj["short_name"] as! String
        self.credits_worth = obj["credits_worth"] as! Float
        self.credits_received = obj["credits_received"] as! Float
        self.link = obj["link"] as! String
        self.module = obj["module"] as! String
        self.status = PassStatus(rawValue: obj["status"] as! String)!
        self.grade = obj["grade"] as! String
    }
}