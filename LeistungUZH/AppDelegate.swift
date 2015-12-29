//
//  AppDelegate.swift
//  LeistungUZH
//
//  Created by Jonny Burger on 08.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    var registrationOptions = [String: AnyObject]()
    var gcmSenderID: String? = "209330605913"
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        NotificationManager.sharedInstance.enablePushNotifications(application);
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
        GCMService.sharedInstance().disconnect()
        // [START_EXCLUDE]
        NotificationManager.sharedInstance.connectedToGCM = false
        // [END_EXCLUDE]
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0;
        if NotificationManager.sharedInstance.connectedToGCM {
            return;
        }
        if NotificationManager.sharedInstance.registrationToken != nil {
            NotificationManager.sharedInstance.connectToGCM()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self;
        
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
            kGGLInstanceIDAPNSServerTypeSandboxOption:false]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            print("Notification received: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
            // [START_EXCLUDE]
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
            // [END_EXCLUDE]
            NotificationManager.sharedInstance.makeUpdate { (UIBackgroundFetchResult) -> Void in
                
        };

    }
    
    func application( application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
            print("Notification received with completion handler: \(userInfo)")
            // This works only if the app started the GCM service
            GCMService.sharedInstance().appDidReceiveMessage(userInfo);
            // Handle the received message
            // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
            // [START_EXCLUDE]
            NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil,
                userInfo: userInfo)
            // [END_EXCLUDE]
            NotificationManager.sharedInstance.makeUpdate(handler);
    }
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            NotificationManager.sharedInstance.registrationToken = registrationToken
            print("Registration Token: \(NotificationManager.sharedInstance.registrationToken)")
            NotificationManager.sharedInstance.connectToGCM()
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
        } else {
            // Will send message, you can save the messageID to track the message
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        // Did successfully send message identified by messageID
    }
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: NSError ) {
            print("Registration for remote notification failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                registrationKey, object: nil, userInfo: userInfo)
    }
}

