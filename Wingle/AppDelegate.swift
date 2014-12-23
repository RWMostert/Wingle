//
//  AppDelegate.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/02.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Enable Crash Reporting
        ParseCrashReporting.enable();
        
        Parse.setApplicationId("KecCbzbfBtohCU2uuyAozy2s5aEVc2LIdpzwcw2W", clientKey: "un0YoSxD6zj7WqqHFVWUAYMHcZHuGFNtfaW0gQNv")
        
        PFFacebookUtils.initializeFacebook()
        
        PFACL.setDefaultACL(PFACL(), withAccessForCurrentUser: true)
        
       // Parse.enableLocalDatastore()
        
        let userNotificationTypes = UIUserNotificationType.Alert | UIUserNotificationType.Badge | UIUserNotificationType.Sound
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        
        /*
        * NSBundle background images
        *
        */
        
        //let vc = ViewController(panDuration: 7.0, withPanSize: 10, andDistantBackgroundImages: ["http://www.hdwallpapersart.com/wp-content/uploads/2013/06/rainy-paris-iphone-5-wallpaper.jpg", "http://cdn.crazyleafdesign.com/blog/wp-content/uploads/2012/10/iphone-5-wallpaper-rain-drops.jpg", "http://blogigoldhouse.com/wp-content/uploads/2012/12/Abstract-iPhone-5-wallpaper-igoldhouse.com_.jpg"], withPlaceholder: ["bg_1.jpg", "bg_2.jpg", "bg_3.jpg", "bg_4.jpg", "bg_5.jpg"])
      
        
        
        /*
        * Distant background images
        
        AOHomeController *vc = [[AOHomeController alloc] initWithPanDuration:7.0f
        withPanSize:10
        andDistantBackgroundImages:@[@"http://www.hdwallpapersart.com/wp-content/uploads/2013/06/rainy-paris-iphone-5-wallpaper.jpg", @"http://cdn.crazyleafdesign.com/blog/wp-content/uploads/2012/10/iphone-5-wallpaper-rain-drops.jpg", @"http://blogigoldhouse.com/wp-content/uploads/2012/12/Abstract-iPhone-5-wallpaper-igoldhouse.com_.jpg"]
        withPlaceholder:@[@"bg_1.jpg", @"bg_2.jpg", @"bg_3.jpg"]];
        */
        
        //window?.rootViewController = vc
        //[self.window setRootViewController:vc];
        //self.window.backgroundColor = [UIColor whiteColor];
        //[self.window makeKeyAndVisible];
        println("GotHere")
        
        
       /* var sb = UIStoryboard(name: "WingleSB", bundle: nil)
        if let tbc = sb.instantiateViewControllerWithIdentifier("wingleTabBar") as? TabBarController {
        
        var controller:PFQueryTableViewController = PFQueryTableViewController(className: "Lounge")
        self.window?.rootViewController = tbc as TabBarController
        }
        println("Done")
        
        */
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBAppEvents.activateApp()
        FBAppCall.handleDidBecomeActiveWithSession(PFFacebookUtils.session())
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return FBSession.activeSession().handleOpenURL(url)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.channels = ["global"]
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        PFPush.handlePush(userInfo)
    }


}

