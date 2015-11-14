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
    let standards = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

