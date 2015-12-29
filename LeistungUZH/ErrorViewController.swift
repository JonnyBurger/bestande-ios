//
//  ErrorViewController.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 02.12.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit
import MessageUI

class ErrorViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var stack : UITextView!
    @IBOutlet var close : UIButton!
    @IBOutlet var send : UIButton!
    var stackmsg : NSString = "";
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        send.addTarget(self, action: "sendClicked", forControlEvents: .TouchUpInside);
        close.addTarget(self, action: "closeClicked", forControlEvents: .TouchUpInside);
        stack.text = stackmsg as String
        stack.setContentOffset(CGPointZero, animated: false);
    }
    
    func closeClicked() {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func showSendMailErrorAlert() {
        let alert = UIAlertController(title: "Konnte E-Mail nicht senden", message: "Bitte checke, ob du E-Mail-Accounts aufgesetzt hast.", preferredStyle: .Alert);
        self.presentViewController(alert, animated: true) { () -> Void in
            
        }
    }
    
    func sendClicked() {
        let mailComposerVC = MFMailComposeViewController();
        mailComposerVC.mailComposeDelegate = self;
        mailComposerVC.setToRecipients(["jonathan.burger@uzh.ch"]);
        mailComposerVC.setSubject("Fehler in Bestande-App");
        mailComposerVC.setMessageBody(stackmsg as String, isHTML: false);
        self.presentViewController(mailComposerVC, animated: true, completion: nil);
    }
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    init(stack: NSString) {
        super.init(nibName: "ErrorViewController", bundle: nil);
        stackmsg = stack as NSString;
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
