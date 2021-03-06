//
//  AppDelegate.swift
//  NewsFeed
//
//  Created by MArko Satlan on 13/05/2018.
//  Copyright © 2018 MArko Satlan. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack(modelName: "NewsFeed")
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        guard let navigationController = window?.rootViewController as? UINavigationController,
              let viewController = navigationController.topViewController as? MainMenuViewController else {
                return true
        }
        
        viewController.managedContext = coreDataStack.managedContext
        
        customizeAppearance()
        
        // remove values to start the application with default settings for first server response
        UserDefaults.standard.removeObject(forKey: "Language")
        UserDefaults.standard.removeObject(forKey: "SegmentedControlIndex")
        UserDefaults.standard.synchronize()
        
        return true
    }

    func customizeAppearance() {
        UIApplication.shared.statusBarStyle = .lightContent
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont.georgia(ofSize: 15)], for: .normal)
        UINavigationBar.appearance().barTintColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor(red: 255/255, green: 238/255, blue: 136/255, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.font: UIFont.georgia(ofSize: 20),
                                                            NSAttributedStringKey.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
        // removes UITableViewCell white flickering on deletion
        UITableViewCell.appearance().backgroundColor = .clear
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveContext()
    }
}

