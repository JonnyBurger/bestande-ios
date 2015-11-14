//
//  FirstViewController.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 08.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit
import Alamofire

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var semesters : [Semester] = []
    var stats : NSDictionary = [:]
    var refreshControl : UIRefreshControl!
    var overlay : UIView = UIView()
    var emptyView : UIView = UIView()
    var hasData : Bool = false
    var noDataReason : NoCreditDataReason = .NOT_TRIED
    func refresh(sender:AnyObject) {
        self.setAuthChangesToFalse()
        
        if (usernameAndPasswordSupplied()) {
            self.refreshControl.beginRefreshing()
            displayLoadingOverlay()
            Alamofire.request(.POST, apiURL() + "/api", parameters: ["username": getUsername()!, "password": getPassword()!])
                .responseJSON { response in
                    if let json = response.result.value {
                        let r = json as! NSDictionary
                        let success = r["success"] as! Bool
                        print("JSON \(json)");
                        if (success) {
                            let semesters = r["credits"] as! NSArray as! [NSDictionary]
                            self.semesters = semesters.map({ (obj: NSDictionary) -> Semester in
                                Semester(obj: obj)
                            })
                            self.stats = r["stats"] as! NSDictionary
                            self.hasData = true
                        }
                        else {
                            self.noDataReason = NoCreditDataReason(rawValue: r["message"] as! String)!
                            self.hasData = false
                        }
                    }
                    else {
                        self.noDataReason = .REQUEST_FAILED
                        self.hasData = false
                    }
                    self.refreshControl.endRefreshing()
                    self.reloadView()
                    self.hideLoadingOverlay()
                
            }
        } else {
            self.noDataReason = .NO_CREDENTIALS_SUPPLIED
            self.hasData = false
            self.reloadView()
        }
    }
    func reloadView() {
        if (authHasChanged()) {
            return self.refresh(self);
        }
        if (hasData) {
            self.tableView.reloadData()
            self.hideNoDataReason()
        }
        else {
            displayNoDataReason()
            if (noDataReason == .NOT_TRIED) {
                self.refresh(self)
            }
        }
    }
    
    func apiURL() -> String {
        let defaults = NSUserDefaults.standardUserDefaults()
        return (defaults.valueForKey("ownServer") as? Bool == true) ? (defaults.valueForKey("server") as! String) : "https://www.bestande.ch"
    }
    
    func hideNoDataReason() {
        self.emptyView.removeFromSuperview()
    }
    
    func getUsername() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
    }
    
    func getPassword() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("password") as? String
    }
    
    func stringIsEmpty(str: String?) -> Bool {
        return str == nil || str?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == ""
    }
    
    func usernameAndPasswordSupplied() -> Bool {
        return !stringIsEmpty(getUsername()) && !stringIsEmpty(getPassword())
    }
    
    func authHasChanged() -> Bool {
        if let changed = NSUserDefaults.standardUserDefaults().valueForKey("authChanged") {
            return changed as! Bool
        }
        else {
            return false
        }
    }
    func setAuthChangesToFalse() {
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "authChanged")
    }
    
    func displayNoDataReason() {
        self.emptyView.subviews.forEach({ $0.removeFromSuperview() })
        let label = UILabel()
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        self.emptyView.frame = self.view.frame
        self.emptyView.backgroundColor = UIColor.whiteColor()
        
        label.text = "Keine Daten."
        label.frame.origin.x = 20
        label.frame.origin.y = self.view.center.y - 50
        label.frame.size.width = self.view.frame.size.width - 40
        label.frame.size.height = 100
        label.font = UIFont(name: label.font.fontName, size: 12)
        label.textAlignment = .Center
        label.alpha = 0.56
        if (noDataReason == .LOGIN_PAGE_LOAD_FAIL) {
            label.text = "Es konnte keine Verbindung zum Authentifizierungsserver hergestellt werden."
        }
        if (noDataReason == .NO_PASSWORD) {
            label.text = "Es wurde kein Passwort angegeben."
        }
        if (noDataReason == .NO_USERNAME) {
            label.text = "Es wurde kein Benutzername angegeben."
        }
        if (noDataReason == .NOT_TRIED) {
            label.text = "Wird geladen..."
        }
        if (noDataReason == .OFFLINE) {
            label.text = "Du bist offline."
        }
        if (noDataReason == .REQUEST_FAILED) {
            if Reachability.isConnectedToNetwork() {
                label.text = "Es konnte keine Verbindung zum Server hergestellt werden."
            }
            else {
                label.text = "Du bist offline."
            }
        }
        if (noDataReason == .SCRAPE_ERROR) {
            label.text = "Der UZH-Server konnte nicht kontaktiert werden."
        }
        if (noDataReason == .SCRAPE_PARSE_ERROR) {
            label.text = "Der UZH-Server hat etwas unerwartetes zurückgegeben."
        }
        if (noDataReason == .SCRAPE_TIMEOUT) {
            label.text = "Der UZH-Server hat zu lange nicht geantwortet."
        }
        if (noDataReason == .USERNAME_PW_WRONG) {
            label.text = "Der UZH-Shortname oder das Passwort ist falsch. Bitte beachte, dass im Moment nur die Universität Zürich unterstützt wird."
        }
        if (noDataReason == .NO_CREDENTIALS_SUPPLIED) {
            label.text = "Willkommen! Bitte logge dich als erstes in deinen UZH-Account ein."
        }
        
        emptyView.addSubview(label)
        
        self.view.addSubview(self.emptyView)
    }
    
    func displayLoadingOverlay() {
        self.overlay.subviews.forEach({ $0.removeFromSuperview() })
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        let label = UILabel()
        self.overlay.frame = self.view.frame
        self.overlay.backgroundColor = UIColor.whiteColor()
        
        activityIndicator.center = overlay.center
        self.overlay.addSubview(activityIndicator)
        
        label.text = "Lade Verzeichnis.."
        self.overlay.addSubview(label)
        label.frame.origin.x = 0
        label.frame.origin.y = self.view.center.y + 10
        label.frame.size.height = 40
        label.frame.size.width = self.view.frame.size.width
        label.font = UIFont(name: label.font.fontName, size: 12)
        label.textAlignment = .Center
        label.alpha = 0.56
        
        self.view.addSubview(self.overlay)
    
        
        activityIndicator.startAnimating()
    }
    
    func hideLoadingOverlay() {
        self.overlay.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        self.refreshControl = UIRefreshControl()
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: .ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.reloadView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return semesters.count + 1
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Übersicht"
        }
        return semesters[section-1].semester
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        return semesters[section-1].credits.count
    }
    func tableViewCellFirst(stats: NSDictionary) -> UITableViewCell {
        let lib = NSBundle.mainBundle().loadNibNamed("StatsCell", owner: self, options: nil) as NSArray
        let cell = (lib.objectAtIndex(0) as? StatsCell)!
        let points = stats["total_credits"] as? Double
        cell.ectsPoints.text = points?.description
        let weight_avg = stats["weighted_average"] as? Double
        cell.avg.text = weight_avg?.description
        return cell
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.row == 0 && indexPath.section == 0) {
            return tableViewCellFirst(self.stats)
        }

        var cell = tableView.dequeueReusableCellWithIdentifier("CreditCell") as? CreditCell
        if cell == nil {
            let lib = NSBundle.mainBundle().loadNibNamed("CreditCell", owner: self, options: nil) as NSArray
            cell = (lib.objectAtIndex(0) as! CreditCell)
        }
        let credit = semesters[indexPath.section - 1].credits[indexPath.row]
        cell!.mainTitle.text = credit.short_name
        cell!.subTitle.text = buildStatus(credit)
        cell!.ects.text = "ECTS: " + credit.credits_worth.description
        if !stringIsEmpty(credit.grade) {
            cell!.grade.text = "Note: " + credit.grade
        }
        else {
            cell!.grade.removeFromSuperview()
        }
        if (credit.status == .PASSED) {
            cell!.color.backgroundColor = UIColor.init(red: 46 / 255, green: 204 / 255, blue: 113 / 255, alpha: 1)
            cell!.subTitle.textColor = UIColor.init(red: 46 / 255, green: 204 / 255, blue: 113 / 255, alpha: 1)
        }
        else if (credit.status == .FAILED) {
            cell!.color.backgroundColor = UIColor.init(red: 192 / 255, green: 57 / 255, blue: 43 / 255, alpha: 1)
            cell!.subTitle.textColor = UIColor.init(red: 192 / 255, green: 57 / 255, blue: 43 / 255, alpha: 1)
        }
        else if (credit.status == .DESELECTED) {
            cell!.color.backgroundColor = UIColor.init(red: 230 / 255, green: 126 / 255, blue: 34 / 255, alpha: 1)
            cell!.subTitle.textColor = UIColor.init(red: 230 / 255, green: 126 / 255, blue: 34 / 255, alpha: 1)
        }
        else {
            cell!.color.backgroundColor = UIColor.init(red: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
            cell!.subTitle.textColor = UIColor.init(red: 52 / 255, green: 152 / 255, blue: 219 / 255, alpha: 1)
        }
        return cell!
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (indexPath.row == 0 && indexPath.section == 0) ? 80 : 66
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 0.0
        }
        return 32.0
        
    }
    func buildStatus(credit: Credit) -> String {
        var result = ""
        if (credit.status == .PASSED) { result += "Bestanden" }
        if (credit.status == .FAILED) { result += "Fehlversuch" }
        if (credit.status == .BOOKED) { result += "Gebucht" }
        if (credit.status == .DESELECTED) { result += "Abgewählt" }
        return result
    }

}

