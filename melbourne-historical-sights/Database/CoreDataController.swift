//
//  CoreDataController.swift
//  melbourne-historical-sights
//
//  Created by Ian Estraikh on 16/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var persistantContainer: NSPersistentContainer
    // Results
    var allSightsFetchedResultsController: NSFetchedResultsController<Sight>?
    
    var locationManager: CLLocationManager?
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        
        persistantContainer = NSPersistentContainer(name: "MelbSights")
        persistantContainer.loadPersistentStores() { (description, error) in if let error = error {
            fatalError("Failed to load Core Data stack: \(error)") }
        }
        
        super.init()
        
        // Check if the app is launched first time
        // https://stackoverflow.com/questions/9964371/how-to-detect-first-time-app-launch-on-an-iphone
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isAppAlreadyLaunchedOnce") == nil {
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            createDefaultEntries()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addSight(name: String, desc: String, latitude: Double, longitude: Double, imageFilename: String?, color: Int16, glyphimage: Int16) -> Sight {
        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into: persistantContainer.viewContext) as! Sight
        sight.name = name
        sight.desc = desc
        if let imageFilename = imageFilename {
            sight.imageFilename = imageFilename
        }
        sight.latitude = latitude
        sight.longitude = longitude
        sight.color = color
        sight.glyphimage = glyphimage

        saveContext()
        
        locationManager?.startMonitoring(for: sight.geoLocation!)
        
        return sight
    }
    
    func addImageFilenameToSight(imageFilename: String, sight: Sight) -> Bool {
        sight.imageFilename = imageFilename

        saveContext()
        return true
    }
    
    func deleteSight(sight: Sight) {
        locationManager?.stopMonitoring(for: sight.geoLocation!)
        
        deleteImageFromDocumentDirectory(imageFilename: sight.imageFilename!)
        
        persistantContainer.viewContext.delete(sight)

        saveContext()
    }
    
    func updateSight(sight: Sight, name: String, desc: String, latitude: Double, longitude: Double, imageFilename: String?, color: Int16, glyphimage: Int16) {
        locationManager?.stopMonitoring(for: sight.geoLocation!)
        
        sight.name = name
        sight.desc = desc
        if let imageFilename = imageFilename {
            sight.imageFilename = imageFilename
        }
        sight.latitude = latitude
        sight.longitude = longitude
        sight.color = color
        sight.glyphimage = glyphimage
        
        saveContext()
        
        locationManager?.startMonitoring(for: sight.geoLocation!)
    }

    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        listener.onSightListChange(change: .update, sights: fetchAllSights())
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllSights() -> [Sight] {
        if allSightsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Sight> = Sight.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allSightsFetchedResultsController = NSFetchedResultsController<Sight>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allSightsFetchedResultsController?.delegate = self
            do {
                try allSightsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)") }
        }
        var sights = [Sight]()
        if allSightsFetchedResultsController?.fetchedObjects != nil {
            sights = (allSightsFetchedResultsController?.fetchedObjects)! }
        return sights
    }
    
    // MARK: - Fetched Results Conttroller Delegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        listeners.invoke {
            (listener) in listener.onSightListChange(change: .update, sights: fetchAllSights())
        }
    }
    
    func createDefaultEntries() {
        // Copy default images from Bundle to Document directory
        guard let defaultImageUrls = Bundle.main.urls(forResourcesWithExtension: "jpg", subdirectory: "DefaultImages") else {
            return
        }
        for imageUrl in defaultImageUrls {
            do {
                let data = try Data(contentsOf: imageUrl)
                let filename = imageUrl.lastPathComponent
                saveImageToDocumentDirectory(data: data, imageFilename: filename)
            } catch {
                print("Error: reading images")
                return
            }
        }
        
        
        if let defaultDataPath = Bundle.main.path(forResource: "DefaultData", ofType: "plist") {
            let plistArray = NSArray(contentsOfFile: defaultDataPath)
            for plistDict in (plistArray as! [NSDictionary]) {
                let name = plistDict["name"] as! String
                let desc = plistDict["desc"] as! String
                let lat = plistDict["latitude"] as! Double
                let lon = plistDict["longitude"] as! Double
                let filename = plistDict["imageFilename"] as! String
                let color = plistDict["color"] as! Int16
                let glyphimage = plistDict["glyphimage"] as! Int16
                
                let _ = addSight(name: name, desc: desc, latitude: lat, longitude: lon, imageFilename: filename, color: color, glyphimage: glyphimage)
            }
        }
    }
}

