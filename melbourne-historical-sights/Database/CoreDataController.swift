//
//  CoreDataController.swift
//  melbourne-historical-sights
//
//  Created by fit5140 on 16/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    
    var persistantContainer: NSPersistentContainer
    // Results
    var allSightsFetchedResultsController: NSFetchedResultsController<Sight>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "MelbSights")
        persistantContainer.loadPersistentStores() { (description, error) in if let error = error {
            fatalError("Failed to load Core Data stack: \(error)") }
        }
        
        super.init()
        
        // Check if app is launched first time
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
    
    func addSight(name: String, desc: String, latitude: Double, longitude: Double, imageFilename: String?) -> Sight {
        let sight = NSEntityDescription.insertNewObject(forEntityName: "Sight", into: persistantContainer.viewContext) as! Sight
        sight.name = name
        sight.desc = desc
        if let imageFilename = imageFilename {
            sight.imageFilename = imageFilename
        }
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return sight
    }
    
    func addImageFilenameToSight(imageFilename: String, sight: Sight) -> Bool {
        sight.imageFilename = imageFilename
        // This less efficient than batching changes and saving once at end.
        saveContext()
        return true
    }
    
    func deleteSight(sight: Sight) {
        persistantContainer.viewContext.delete(sight)
        // This less efficient than batching changes and saving once at end.
        saveContext()
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
                
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let documentUrl = NSURL(fileURLWithPath: path)
                
                if let pathComponent = documentUrl.appendingPathComponent("\(filename)") {
                    let filePath = pathComponent.path
                    let fileManager = FileManager.default
                    fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
                }
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
                let long = plistDict["longitude"] as! Double
                let filename = plistDict["imageFilename"] as! String
                
                let _ = addSight(name: name, desc: desc, latitude: lat, longitude: long, imageFilename: filename)
            }
        }
    }
}

