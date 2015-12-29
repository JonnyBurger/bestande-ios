//
//  Room.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 07.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation


class Room {
    var link : String = ""
    var name : String = ""
    var building : Building;
    var room : String = "";
    var plan : String? = "";
    
    init(obj: NSDictionary) {
        self.link = obj["link"] as! String;
        self.name = obj["name"] as! String;
        self.building = Building(obj: obj["building"] as! NSDictionary);
        self.room = obj["room"] as! String;
        self.plan = obj["plan"] as? String;
    }
}