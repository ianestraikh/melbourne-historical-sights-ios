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
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (granted, error) in
            if !granted {
                print("Permission was not granted!")
                return
            }
        }
        
        databaseController = CoreDataController()
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let notificationContent = UNMutableNotificationContent()
        // Create its details
        notificationContent.title = "This is a notification!"
        notificationContent.subtitle = "FIT5140"
        notificationContent.body = "The application has sent a notification"
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "This is a notification!"
        notificationContent.subtitle = "FIT5140"
        notificationContent.body = "The application has sent a notification"
    }
}

