//
//  AppDelegate.swift
//  Morse Decoder
//
//  Created by Eli Byers on 11/3/17.
//  Copyright © 2017 Eli Byers. All rights reserved.
//

import UIKit
import CoreData

class UI: NSObject {
    static let Purple = UIColor(red: 148/255, green: 55/255, blue: 255/255, alpha: 1)
    static let Green = UIColor(red: 0/255, green: 188/255, blue: 96/255, alpha: 1)
    static let Orange = UIColor.orange
    static let Blue = UIColor(red: 71/255, green: 159/255, blue: 248/255, alpha: 1)
    static let Gray = UIColor(white: 0.2, alpha: 1)
    
    static func colorFor(tag: Int) -> UIColor? {
        let colors = [UI.Purple, UI.Green, UI.Orange, UI.Blue]
        if 0 <= tag && tag <= colors.count { return colors[tag] }
        return nil
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let defaults = UserDefaults.standard
    
    func setUIColor(_ tag: Int){
        defaults.setValue (tag, forKey: "UIColor")
        let color = UI.colorFor(tag: tag)
        
        UINavigationBar.appearance().barTintColor = color
        window?.tintColor = color
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if defaults.value(forKey: "UIColor") == nil {
            defaults.set(3, forKey: "UIColor")
            defaults.set(false, forKey: "NightMode")
        }
        
        let tag = defaults.value(forKey: "UIColor") as! Int
        setUIColor(tag)
        
        // white nav
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        
//        UINavigationBar.appearance().barTintColor = UIColor(red: 76/255, green: 161/266, blue: 245/255, alpha: 1)
//        UINavigationBar.appearance().tintColor = .white
//        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Morse_Decoder")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

