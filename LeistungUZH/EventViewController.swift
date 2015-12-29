//
//  EventViewController.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 29.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit


class EventViewController: UITableViewController {
    var event : Event!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(event.getTitle()) \(event.number)";

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Datum & Zeit";
        }
        if section == 1 {
            return "Räume";
        }
        if section == 2 {
            return "Dozierende";
        }
        return nil;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2;
        }
        if section == 1 {
            return event.rooms.count;
        }
        if section == 2 {
            return event.lecturers.count;
        }
        return 0;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Value1, reuseIdentifier: "anything");
        if (indexPath.section == 0) {
            cell.selectionStyle = .None;
            if (indexPath.row == 0) {
                cell.textLabel?.text = "Datum";
                cell.detailTextLabel?.text = event.getDate();
            }
            if (indexPath.row == 1) {
                cell.textLabel?.text = "Zeit";
                cell.detailTextLabel?.text = event.getTime();
            }
            
        }
        if indexPath.section == 1 {
            let room = event.rooms[indexPath.row];
            if room.building != nil {
                cell.textLabel?.text = room.building!.code;
                cell.detailTextLabel?.text = room.room;
            }
            else {
                cell.textLabel?.text = room.name;
            }
 
        }
        if indexPath.section == 2 {
            cell.textLabel?.text = event.lecturers[indexPath.row].name;
            cell.detailTextLabel?.text = "uzh.ch";
        }
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let room = event.rooms[indexPath.row];
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet);
            let googleURL = "comgooglemaps://";
            
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: googleURL)!) && room.building != nil {
                alertController.addAction(UIAlertAction(title: "Google Maps", style: .Default, handler: { (UIAlertAction) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: "\(googleURL)?q=\(room.building!.latitude),\(room.building!.longitude)&zoom=14&views=satellite,transit")!)
                }))
            }
            
            if room.building != nil {
                alertController.addAction(UIAlertAction(title: "Apple Maps", style: .Default, handler: { (UIAlertAction) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?ll=\(room.building!.latitude),\(room.building!.longitude)")!)
                    
                }));
            }
            
            alertController.addAction(UIAlertAction(title: "Vorlesungsverzeichnis", style: .Default, handler: { (UIAlertAction) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: room.link)!)
            }));
            
            if room.plan != nil {
                alertController.addAction(UIAlertAction(title: "Plan für \(self.event.rooms[indexPath.row].room)", style: .Default, handler: { (UIAlertAction) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: self.event.rooms[indexPath.row].plan!)!);
                }));

            }
        
            
            alertController.addAction(UIAlertAction(title: "Abbrechen", style: .Cancel, handler: nil));
            
            self.presentViewController(alertController, animated: true, completion: nil);
        }
        if indexPath.section == 2 {
            UIApplication.sharedApplication().openURL(NSURL(string: event.lecturers[indexPath.row].link)!)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
}
