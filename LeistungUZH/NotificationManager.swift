//
//  NotificationManager.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 02.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation

class NotificationManager {
    static let sharedInstance = NotificationManager();
    var registrationToken: String?
    var connectedToGCM : Bool = false
    
    func enablePushNotifications(application: UIApplication) {
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil);
        application.registerUserNotificationSettings(settings);
        application.registerForRemoteNotifications();
    }
    
    func makeNotification(label: String, badge: Int) {
        UIApplication.sharedApplication().cancelAllLocalNotifications();
        let notification = UILocalNotification();
        notification.fireDate = NSDate().dateByAddingTimeInterval(1);
        notification.alertBody = label;
        notification.applicationIconBadgeNumber = badge;
        notification.soundName = UILocalNotificationDefaultSoundName;
        UIApplication.sharedApplication().scheduleLocalNotification(notification);
    }
    
    func makeUpdate(completionHandler: (UIBackgroundFetchResult) -> Void) {
        if (RequestManager.sharedInstance.usernameAndPasswordSupplied()) {
            RequestManager.sharedInstance.makeRequest({ (response) -> () in
                if response.hasData {
                    var count : Int = 0;
                    for semester in response.semesters {
                        for credit in semester.credits {
                            if credit.status == .PASSED || credit.status == .FAILED {
                                count++;
                            }
                        }
                    }
                    let newCount = self.getNewCount(count);
                    if (newCount > 0) {
                        self.makeNotification("Neue Note erhalten!", badge: count);
                    }
                    let date = NSDate()
                    let formatter = NSDateFormatter()
                    formatter.timeStyle = .ShortStyle
                    formatter.stringFromDate(date)
                    self.postIntervalUpdate("Letze Aktualisierung um " + formatter.stringFromDate(date))
                    completionHandler(.NewData);
                }
                else {
                    let date = NSDate()
                    let formatter = NSDateFormatter()
                    formatter.timeStyle = .ShortStyle
                    formatter.stringFromDate(date)
                    self.postIntervalUpdate("Fehlgeschlagen um " + formatter.stringFromDate(date));
                    completionHandler(.NoData);
                }
            });
        }
        else {
            completionHandler(.NoData)
        }
    }
    
    func subscribeToTopic(topic: String, completionHandler: (success: Bool) -> ()) {
        if (registrationToken == nil || !connectedToGCM) {
            completionHandler(success: false);
            return postIntervalUpdate("Verbindung fehlgeschlagen.");
        }
        self.postIntervalUpdate("Speichern...");
        GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: topic,
            options: nil, handler: {(NSError error) -> Void in
                if (error == nil || error.code == 3001) {
                    self.postIntervalUpdate("Einstellungen gespeichert.");
                    completionHandler(success: true);
                } else {
                    completionHandler(success: false);
                    self.postIntervalUpdate("Fehler: " + error.localizedDescription);
                }
        })
    }
    
    func connectToGCM() {
        GCMService.sharedInstance().connectWithHandler({
            (NSError error) -> Void in
            if error != nil {
                print("Could not connect to GCM: \(error.localizedDescription)")
            } else {
                self.connectedToGCM = true
                print("Connected to GCM")
            }
        })
    }
    
    func getNewCount(count: Int) -> Int {
        let oldCount = NSUserDefaults.standardUserDefaults().integerForKey("creditCount");
        NSUserDefaults.standardUserDefaults().setInteger(count, forKey: "creditCount");
        return count - oldCount;
    }
    
    func getBatch() -> Int {
        let batch = NSUserDefaults.standardUserDefaults().valueForKey("batch") as? Int;
        if batch != nil {
            return batch!;
        }
        let _generated = Int(arc4random_uniform(15));
        NSUserDefaults.standardUserDefaults().setInteger(_generated, forKey: "batch");
        print("My batch # is \(_generated)");
        return _generated;
    }
    func postIntervalUpdate(message: String) {
        NSUserDefaults.standardUserDefaults().setValue(message, forKey: "interval-info");
        NSNotificationCenter.defaultCenter().postNotificationName("interval-info", object: nil, userInfo: ["message": message]);
    }
    func unsubcribeTopic(topic: String) {
        GCMPubSub.sharedInstance().unsubscribeWithToken(self.registrationToken, topic: topic, options: nil) { (NSError error) -> Void in
            if (error == nil || error.code == 3002) {
                print("\(topic) deabonniert.");
            }
            else {
                self.postIntervalUpdate("Fehler:" + error.localizedDescription);
            }
        }
    }
    func unsubscribeAll() {
        let topics = getTopicsToUnsubscribe()
        for (var i = 0; i < topics.count; i++) {
            unsubcribeTopic(topics[i]);
        }
    }
    
    func getCurrentInterval() -> Intervals {
        if (!hasPermission()) {
            return .MANUALLY;
        }
        let intervalHash = NSUserDefaults.standardUserDefaults().stringForKey("interval");
        if intervalHash != nil {
            let interval = Intervals(rawValue: intervalHash!)
            return interval!;
        }
        NSUserDefaults.standardUserDefaults().setValue(Intervals.MANUALLY as? AnyObject, forKey: "interval");
        return Intervals.MANUALLY;
    }
    
    func hasPermission() -> Bool {
        if let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        {
            if settings.types.contains(.Alert)
            {
                return true;
            }
        }
        return false;
    }
    
    func setCurrentInterval(interval: Intervals, completionHandler: (success: Bool) -> ()) {
        if (interval != .MANUALLY && !hasPermission()) {
            let alert = UIAlertController(title: "Fehlgeschlagen", message: "Du hast die Benachrichtigungen ausgeschaltet. Schalte sie in der Einstellungen-App wieder ein, um sie wieder zu aktivieren.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil));
            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil);
            completionHandler(success: false);
            return;
        }
        subscribeToTopic(getTopicToSubscribe(interval)) { (success) -> () in
            completionHandler(success: success)
            if success {
                NSUserDefaults.standardUserDefaults().setValue(interval.rawValue, forKey: "interval");
                self.unsubscribeAll();
            }
        }
    }
    
    
    func getTopicsToUnsubscribe() -> [String] {
        let batch = getBatch().description;
        let currentInterval = getCurrentInterval()
        var toUnsub = [] as [String];
        if currentInterval != .MANUALLY {
            toUnsub.append("/topics/0");
        }
        if currentInterval != .MIN_15 {
            toUnsub.append("/topics/15min-" + batch)
        }
        if currentInterval != .MIN_30 {
            toUnsub.append("/topics/30min-" + batch)
        }
        if currentInterval != .MIN_60 {
            toUnsub.append("/topics/60min-" + batch)
        }
        if currentInterval != .HOUR_3 {
            toUnsub.append("/topics/3hour-" + batch)
        }
        if currentInterval != .HOUR_8 {
            toUnsub.append("/topics/8hour-" + batch)
        }
        return toUnsub;
    }
    
    func getTopicToSubscribe(currentInterval: Intervals) -> String {
        let batch = getBatch().description;
        if currentInterval == .MANUALLY {
            return "/topics/0"
        }
        else if currentInterval == .MIN_15 {
            return "/topics/15min-" + batch;
        }
        else if currentInterval == .MIN_30 {
            return "/topics/30min-" + batch;
        }
        else if currentInterval == .MIN_60 {
            return "/topics/60min-" + batch;
        }
        else if currentInterval == .HOUR_3 {
            return "/topics/3hour-" + batch;
        }
        else if currentInterval == .HOUR_8 {
            return "/topics/8hour-" + batch;
        }
        return "/topics/0";
    }

}