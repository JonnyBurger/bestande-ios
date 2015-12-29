//
//  CourseDetailViewController.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 06.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit

class CourseDetailViewController: UITableViewController {
    var courseURL : String = ""
    var credit : Credit!
    var countsTowardsAvgCell : CountsTowardsAvgCell = CountsTowardsAvgCell()
    var events : [Event] = [];
    var upcomingEvents : [Event] = [];
    var pastEvents : [Event] = [];
    
    var eventSelected : Event?;
    
    var loading = true;
    
    func makeRequest() {
        RequestManager.sharedInstance.getEvents(credit) { (response: [Event]) -> () in
            self.events = response;
            self.upcomingEvents = self.events.filter({ (event: Event) -> Bool in
                !event.isInPast()
            });
            self.pastEvents = self.events.filter({ (event: Event) -> Bool in
                event.isInPast()
            })
            self.loading = false;
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.makeRequest()
        self.title = credit.short_name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            countsTowardsAvgCell.switched();
            countsTowardsAvgCell.updateCountsSwitch(true)
        }
        else {
            if indexPath.section == 1 {
                eventSelected = upcomingEvents[indexPath.row];
            }
            else if indexPath.section == 2 {
                eventSelected = pastEvents[indexPath.row];
            }
            self.performSegueWithIdentifier("EventTransition", sender: self);
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1;
        }
        if section == 1 {
            if loading {
                return 1;
            }
            return max(upcomingEvents.count, 1);
        }
        if section == 2 {
            if loading {
                return 1;
            }
            return max(pastEvents.count, 1);
        }
        return 0;
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0 && indexPath.row == 0) {
            return 48;
        }
        if indexPath.section == 1 || indexPath.section == 2 {
            return 63;
        }
        return 48;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Als nächstes";
        }
        if section == 2 {
            return "Vergangene Veranstaltungen"
        }
        return nil;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let lib = NSBundle.mainBundle().loadNibNamed("CountsTowardsAvgCell", owner: self, options: nil) as NSArray
                countsTowardsAvgCell = (lib.objectAtIndex(0) as? CountsTowardsAvgCell)!
                countsTowardsAvgCell.credit = credit;
                if (!CountsTowardsAvgPersister.sharedInstance.canCount(credit)) {
                    countsTowardsAvgCell.setCellAsInactive();
                    countsTowardsAvgCell.selectionStyle = .None;
                }
                return countsTowardsAvgCell;
            }
        }
        if indexPath.section == 1 || indexPath.section == 2 {
            let eventsToUse = indexPath.section == 1 ? self.upcomingEvents : self.pastEvents;
            if eventsToUse.count == indexPath.row {
                let cell = UITableViewCell(style: .Default, reuseIdentifier: "Empty");
                cell.textLabel?.text = loading ? "Laden.." : "Keine Veranstaltungen"
                cell.textLabel?.textColor = UIColor.grayColor()
                return cell;
            }
            else {
                let lib = NSBundle.mainBundle().loadNibNamed("EventCell", owner: self, options: nil) as NSArray
                let cell = (lib.objectAtIndex(0) as? EventCell)!
                cell.setEvent(eventsToUse[indexPath.row]);
                return cell
            }
        }
        return UITableViewCell(style: .Default, reuseIdentifier: "test");
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "EventTransition") {
            let nextController = segue.destinationViewController as! EventViewController;
            nextController.event = eventSelected!;
        }
    }
    
}
