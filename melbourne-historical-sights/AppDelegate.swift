//
//  AppDelegate.swift
//  Melbourne Historical Sights
//
//  Created by Ian Estraikh on 16/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var databaseController: DatabaseProtocol?
    
    var locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let uiProxy = UINavigationBar.appearance()
        uiProxy.barTintColor = UIColor(red:0.40, green:0.50, blue:0.35, alpha:1.0)
        uiProxy.tintColor = UIColor.white
        uiProxy.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.window?.tintColor = UIColor(red:0.40, green:0.50, blue:0.35, alpha:1.0)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
        
        databaseController = CoreDataController(locationManager: locationManager)
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Great! You made it!"
        notificationContent.body = "You are in radius of 50 m around \(region.identifier)"
        
        let request = UNNotificationRequest(identifier: "MelbSights", content: notificationContent, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        if let view = self.window?.rootViewController {
            displayMessage("You are in radius of 50 m around \(region.identifier)", "Great! You made it!", view)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "You left radius of 50 m around \(region.identifier)"
        notificationContent.body = "Oops you are leaving!"
        
        let request = UNNotificationRequest(identifier: "MelbSights", content: notificationContent, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        if let view = self.window?.rootViewController {
            displayMessage("You left radius of 50 m around \(region.identifier)", "Oops, you are leaving!", view)
        }
    }
}

