//
//  SecondViewController.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 08.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController {
    @IBOutlet var usernameInput : UITextField!
    @IBOutlet var passwordInput : UITextField!
    
    @IBOutlet var disableCustomServerCell : UITableViewCell!
    @IBOutlet var enableCustomServerCell : UITableViewCell!
    @IBOutlet var customServerInput : UITextField!

    @IBOutlet var intervalStatus : UITableViewCell!
    
    @IBOutlet var intervalZero : UITableViewCell!
    @IBOutlet var interval15 : UITableViewCell!
    @IBOutlet var interval30 : UITableViewCell!
    @IBOutlet var interval60 : UITableViewCell!
    @IBOutlet var interval180 : UITableViewCell!
    @IBOutlet var interval480 : UITableViewCell!
    
    @IBOutlet var website : UITableViewCell!
    
    var intervalCells : [UITableViewCell] = []
    
    let standards = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad();
        
        intervalCells = [intervalZero, interval15, interval30, interval60, interval180, interval480];
        
        if let username = standards.valueForKey("username") as? String {
            usernameInput.text = username
        }
        usernameInput.addTarget(self, action: "usernameChanged", forControlEvents: .EditingChanged)
        usernameInput.addTarget(self, action: "focusPasswordField", forControlEvents: .EditingDidEndOnExit)
        
        if let password = standards.valueForKey("password") as? String {
            passwordInput.text = password
        }
        passwordInput.addTarget(self, action: "passwordChanged", forControlEvents: .EditingChanged)
        passwordInput.addTarget(self, action: "dismissKeyboard", forControlEvents: .EditingDidEndOnExit)
        
        if (ownServerIsEnabled()) {
            enableOwnServer()
        }
        else {
            disableOwnServer()
        }
        customServerInput.addTarget(self, action: "enableOwnServer", forControlEvents: .EditingDidBegin)
        customServerInput.addTarget(self, action: "updateCustomServer", forControlEvents: .EditingChanged)
        customServerInput.addTarget(self, action: "dismissKeyboard", forControlEvents: .EditingDidEndOnExit)
        if let customServer = standards.valueForKey("server") as? String {
            customServerInput.text = customServer
        }
        let adjustForTabbarInsets = UIEdgeInsetsMake(0, 0, 100, 0);
        self.tableView.scrollIndicatorInsets = adjustForTabbarInsets;
        self.tableView.contentInset = adjustForTabbarInsets;
        let intervalStatus = NSUserDefaults.standardUserDefaults().valueForKey("interval-info") as? String;
        if intervalStatus != nil {
            setIVstatus(intervalStatus!);
        }
        else {
            setIVstatus("Keine Aktualisierung bisher")
        }
        NSNotificationCenter.defaultCenter().addObserverForName("interval-info", object: nil, queue: nil) { (notif: NSNotification) -> Void in
            let message = notif.userInfo!["message"] as! String;
            self.setIVstatus(message);
        }
        
        website.textLabel?.text = "www.bestande.ch";
        
        setCheckmarkInitial()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setIVstatus(message: String) {
        self.intervalStatus.textLabel?.text = message;
        self.intervalStatus.textLabel?.textColor = UIColor.grayColor()
    }
    
    func usernameChanged() {
        standards.setObject(usernameInput.text, forKey: "username")
        standards.setObject(true, forKey: "authChanged")
    }
    
    func passwordChanged() {
        standards.setObject(passwordInput.text, forKey: "password")
        standards.setObject(true, forKey: "authChanged")
    }
    
    func focusPasswordField() {
        passwordInput.becomeFirstResponder()
    }
    
    func dismissKeyboard() {
        passwordInput.resignFirstResponder()
        customServerInput.resignFirstResponder()
    }
    
    func disableAllServerCheckmarks() {
        enableCustomServerCell.accessoryType = .None
        disableCustomServerCell.accessoryType = .None
    }
    
    func ownServerIsEnabled() -> Bool {
        let value = standards.valueForKey("ownServer")
        return (value as? Bool) == true
    }
    
    func updateCustomServer() {
        standards.setObject(customServerInput.text, forKey: "server")
        standards.setObject(true, forKey: "authChanged")
    }
    
    func enableOwnServer() {
        disableAllServerCheckmarks()
        enableCustomServerCell.accessoryType = .Checkmark
        standards.setObject(true, forKey: "ownServer")
    }
    func disableOwnServer() {
        disableAllServerCheckmarks()
        disableCustomServerCell.accessoryType = .Checkmark
        standards.setObject(false, forKey: "ownServer")
        customServerInput.resignFirstResponder()
    }
    
    func turnIntervalOff() {
        NotificationManager.sharedInstance.unsubscribeAll();
    }
    
    func disableAllIntervalProps() {
        intervalCells.forEach { (cell: UITableViewCell) -> () in
            cell.accessoryType = .None
            cell.accessoryView = nil;
        }
    }
    
    func setSpinnerForCell(cell: UITableViewCell) {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner.frame = CGRectMake(0, 0, 24, 24);
        cell.accessoryView = spinner;
        spinner.startAnimating()
    }
    
    func setCheckmarkForCell(cell: UITableViewCell) {
        cell.accessoryView = nil;
        cell.accessoryType = .Checkmark
    }
    
    func setCheckmarkInitial() {
        disableAllIntervalProps()
        let interval = NotificationManager.sharedInstance.getCurrentInterval()
        if interval == .MIN_15 {
            setCheckmarkForCell(self.interval15)
        }
        else if interval == .MIN_30 {
            setCheckmarkForCell(self.interval30)
        }
        else if interval == .MIN_60 {
            setCheckmarkForCell(self.interval60)
        }
        else if interval == .HOUR_3 {
            setCheckmarkForCell(self.interval180)
        }
        else if interval == .HOUR_8 {
            setCheckmarkForCell(self.interval480)
        }
        else {
            setCheckmarkForCell(self.intervalZero)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1 && indexPath.row < 2) {
            if (indexPath.row == 0) {
                disableOwnServer()
            }
            else {
                enableOwnServer()
            }
            standards.setObject(true, forKey: "authChanged")
        }
        if (indexPath.section == 2) {
            disableAllIntervalProps()
            if (indexPath != 0) {
                NotificationManager.sharedInstance.enablePushNotifications(UIApplication.sharedApplication());
            }
        }
        if (indexPath.section == 2 && indexPath.row == 0) {
            setSpinnerForCell(intervalZero)
            NotificationManager.sharedInstance.setCurrentInterval(Intervals.MANUALLY, completionHandler: { (success) -> () in
                if (success) {
                    self.setCheckmarkForCell(self.intervalZero)
                }
                else { self.setCheckmarkInitial() }
            })
        }
        else if (indexPath.section == 2 && indexPath.row == 1) {
            setSpinnerForCell(interval15)
            NotificationManager.sharedInstance.setCurrentInterval(Intervals.MIN_15, completionHandler: { (success) -> () in
                if (success) {
                    self.setCheckmarkForCell(self.interval15);
                }
                else { self.setCheckmarkInitial() }
            })
        }
        else if (indexPath.section == 2 && indexPath.row == 2) {
            setSpinnerForCell(interval30)
            NotificationManager.sharedInstance.setCurrentInterval(Intervals.MIN_30, completionHandler: { (success) -> () in
                if (success) {
                    self.setCheckmarkForCell(self.interval30);
                }
                else { self.setCheckmarkInitial() }
            })
        }
        else if (indexPath.section == 2 && indexPath.row == 3) {
            setSpinnerForCell(interval60)
            NotificationManager.sharedInstance.setCurrentInterval(Intervals.MIN_60, completionHandler: { (success) -> () in
                if (success) {
                    self.setCheckmarkForCell(self.interval60);
                }
                else { self.setCheckmarkInitial() }
            })
        }
        else if (indexPath.section == 2 && indexPath.row == 4) {
            setSpinnerForCell(interval180)
            NotificationManager.sharedInstance.setCurrentInterval(Intervals.HOUR_3, completionHandler: { (success) -> () in
                if (success) {
                    self.setCheckmarkForCell(self.interval180);
                }
                else { self.setCheckmarkInitial() }
            })
        }
        else if (indexPath.section == 2 && indexPath.row == 5) {
            setSpinnerForCell(interval480)
            NotificationManager.sharedInstance.setCurrentInterval(Intervals.HOUR_8, completionHandler: { (success) -> () in
                if (success) {
                    self.setCheckmarkForCell(self.interval480);
                }
                else { self.setCheckmarkInitial() }
            })
        }
        if (indexPath.section == 4) {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.bestande.ch")!)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

