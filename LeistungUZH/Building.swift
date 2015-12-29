//
//  Building.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 29.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation


class Building {
    var code : String = "BIN";
    var longitude : Float = 0.0000;
    var latitude : Float = 0.0000;
    var features : [BuildingFeature] = [];
    
    init (obj: NSDictionary) {
        self.code = obj["code"] as! String;
        self.longitude = obj["longitude"] as! Float;
        self.latitude = obj["latitude"] as! Float;
        self.features = (obj["features"] as! [String]).map({ (str: String) -> BuildingFeature in
            BuildingFeature(rawValue: str)!;
        });
    }
    
}