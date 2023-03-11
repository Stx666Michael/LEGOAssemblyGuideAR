//
//  AppDelegate.swift
//  LEGOAssemblyGuide
//
//  Created by Tianxiang Song on 05/10/22.
//  Copyright © 2022 Tianxiang Song. All rights reserved.
//

import UIKit

@UIApplicationMain
/// The app delegate class for the application. This class is responsible for handling major application lifecycle events and acts as a central point for managing application resources.
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// A property that stores the app's window object, which provides the coordinate system for views displayed on the screen.
    var window: UIWindow?

    /// A method that is called when the app finishes launching. It is an opportunity to perform any setup work such as initializing third-party libraries, configuring user interface, and creating the initial view controller for the app.
    /// - Parameters:
    ///   - application: The centralized point of control and coordination for apps running in iOS.
    ///   - launchOptions: The app's UI and other settings.
    /// - Returns: `true` if the app successfully launched, otherwise it should return `false`
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    /// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    /// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    /// - Parameter application: The centralized point of control and coordination for apps running in iOS.
    func applicationWillResignActive(_ application: UIApplication) {}
    
    /// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    /// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    /// - Parameter application: The centralized point of control and coordination for apps running in iOS.
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    /// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    /// - Parameter application: The centralized point of control and coordination for apps running in iOS.
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    /// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /// - Parameter application: The centralized point of control and coordination for apps running in iOS.
    func applicationDidBecomeActive(_ application: UIApplication) {}
    
    /// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    /// - Parameter application: The centralized point of control and coordination for apps running in iOS.
    func applicationWillTerminate(_ application: UIApplication) {}

}
