//
//  RequestManager.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 18.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation
import Alamofire

class RequestManager {
    static let sharedInstance = RequestManager();
    
    func makeRequest(completionHandler: (response: CreditResponse) -> ()) {
         Alamofire.request(.POST, apiURL() + "/api", parameters: ["username": getUsername()!, "password": getPassword()!])
            .responseJSON { response in
                let responseObject = CreditResponse()
                if let json = response.result.value {
                    let r = json as! NSDictionary
                    let success = r["success"] as! Bool
                    if (success) {
                        responseObject.hasData = true;
                        let semesters = r["credits"] as! NSArray as! [NSDictionary]
                        let semesterObject = semesters.map({ (obj: NSDictionary) -> Semester in
                            Semester(obj: obj)
                        })
                        responseObject.semesters = semesterObject
                        responseObject.stats = r["stats"] as! NSDictionary;
                    }
                    else {
                        let message = r["message"] as? String;
                        if message != nil {
                            let ndr = NoCreditDataReason(rawValue: message!);
                            if ndr != nil {
                                responseObject.noDataReason = ndr!;
                            }
                            else {
                                responseObject.noDataReason = .OTHER_REASON;
                            }
                        }
                        else {
                            responseObject.noDataReason = .OTHER_REASON;
                        }
                        responseObject.hasData = false
                        responseObject.stack = (r["stack"] as? String)!;
                    }
                }
                else {
                    responseObject.noDataReason = NoCreditDataReason.REQUEST_FAILED
                    responseObject.hasData = false
                }
                completionHandler(response: responseObject);
                
        }
    }
    
    func getUsername() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
    }
    
    func getPassword() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("password") as? String
    }
    func apiURL() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        return (defaults.valueForKey("ownServer") as? Bool == true) ? (defaults.valueForKey("server") as! String) : "https://www.bestande.ch"
    }
    func usernameAndPasswordSupplied() -> Bool {
        return !stringIsEmpty(getUsername()) && !stringIsEmpty(getPassword())
    }
    func stringIsEmpty(str: String?) -> Bool {
        return str == nil || str?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == ""
    }
    
    
    // Events
    
    func getEvents(credit: Credit, completionHandler: (response: [Event]) -> ()) {
        Alamofire.request(.GET, apiURL() + "/api/vorlesung?url=" + credit.link)
        .responseJSON { response in
            if let json = response.result.value {
                let r = json as! NSDictionary
                let success = r["success"] as! Bool
                
                if success {
                    let events = r["data"] as! [NSDictionary];
                    let eventsObject = events.map({ (obj: NSDictionary) -> Event in
                        Event(obj: obj)
                    })
                    completionHandler(response: eventsObject);
                }
            }
        }
    }
}