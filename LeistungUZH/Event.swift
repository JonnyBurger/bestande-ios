//
//  Event.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 07.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation


class Event {
    var rooms : [Room] = []
    var lecturers : [Lecturer] = []
    var type : EventType = .SONSTIGES
    var startdate : NSDate;
    var enddate : NSDate;
    var number : String = "";
    init(obj: NSDictionary) {
        self.rooms = (obj["rooms"] as! [NSDictionary]).map({ (obj: NSDictionary) -> Room in
            Room(obj: obj)
        });
        self.lecturers = (obj["lecturers"] as! [NSDictionary]).map({ (obj: NSDictionary) -> Lecturer in
            Lecturer(link: obj["link"] as! String, name: obj["name"] as! String)
        });
        self.type = EventType(rawValue: obj["type"] as! String)!;
        self.startdate = NSDate(timeIntervalSince1970: Double(obj["starttime"] as! Int) / 1000)
        self.enddate = NSDate(timeIntervalSince1970: Double(obj["endtime"] as! Int) / 1000)
        self.number = obj["number"] as! String
    }
    
    func getTitle() -> String {
        if self.type == EventType.ARBEIT {
            return "Arbeit"
        }
        if self.type == EventType.BLOCKKURS {
            return "Blockkurs"
        }
        if self.type == EventType.EXKURSION {
            return "Exkursion"
        }
        if self.type == EventType.KOLLOQUIUM {
            return "Kolloquium"
        }
        if self.type == EventType.PRAKTIKUM {
            return "Praktikum"
        }
        if self.type == EventType.PROSEMINAR {
            return "Proseminar"
        }
        if self.type == EventType.PRUEFUNG {
            return "Prüfung"
        }
        if self.type == EventType.SELBSTSTUDIUM {
            return "Selbststudium"
        }
        if self.type == EventType.SEMINAR {
            return "Seminar"
        }
        if self.type == EventType.SPRACHKURS {
            return "Sprachkurs"
        }
        if self.type == .SPRACHLABOR {
            return "Sprachlabor"
        }
        if self.type == .UEBUNG {
            return "Übung"
        }
        if self.type == .VORLESUNG {
            return "Vorlesung"
        }
        if self.type == .VORLESUNGUEBUNG {
            return "Vorlesung mit integrierter Übung"
        }
        return "Sonstiges"
    }
    
    func getDay() -> String {
        let calendar = NSCalendar.currentCalendar()
        let targetWeek = calendar.components(.WeekOfYear, fromDate: self.enddate);
        let currentWeek = calendar.components(.WeekOfYear, fromDate: NSDate(timeIntervalSinceNow: 0));
        let targetYear = calendar.components(.Year, fromDate: self.enddate);
        let currentYear = calendar.components(.Year, fromDate: NSDate(timeIntervalSinceNow: 0));
        
        // Montag, Dienstag...
        if targetWeek.weekOfYear == currentWeek.weekOfYear && targetYear.year == currentYear.year {
            let formatter =  NSDateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.stringFromDate(self.enddate);
        }
        // nächsten Montag, nächsten Dienstag...
        if targetWeek.weekOfYear == (currentWeek.weekOfYear + 1) && targetYear.year == currentYear.year {
            let formatter = NSDateFormatter();
            formatter.dateFormat = "EEEE";
            return "nächsten \(formatter.stringFromDate(self.enddate))";
        }
        return getDate();
    }
    
    func getDate() -> String {
        let dateformatter = NSDateFormatter()
        dateformatter.dateStyle = .MediumStyle
        dateformatter.timeStyle = .NoStyle
        let weekdayFormatter = NSDateFormatter()
        weekdayFormatter.dateFormat = "EE";
        return weekdayFormatter.stringFromDate(self.enddate) +  " " + dateformatter.stringFromDate(self.enddate)
    }
    
    func getTime() -> String {
        let timeformatter = NSDateFormatter();
        
        timeformatter.dateStyle = .NoStyle;
        timeformatter.timeStyle = .ShortStyle;
        
        return timeformatter.stringFromDate(self.startdate) + " - " + timeformatter.stringFromDate(self.enddate);
    }
    
    func getSubTitle() -> String {
        var subtitle = ""
        
        subtitle += getDay()
        subtitle += ", "
        
        subtitle += getTime()
        
        subtitle += ", "
        subtitle += self.rooms.map({ (room: Room) -> String in
            room.name
        }).joinWithSeparator(", ");
        return subtitle;
        
    }
    
    func isInPast() -> Bool {
        return NSDate(timeIntervalSinceNow: 0).compare(self.enddate) == .OrderedDescending
    }
}