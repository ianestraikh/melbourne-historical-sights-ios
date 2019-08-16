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
        if fetchAllSights().count == 0 {
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
        let _ = addSight(name: "St Patrick's Cathedral", desc: "Approach the mother church of the Catholic Archdiocese of Melbourne from the impressive Pilgrim Path, absorbing the tranquil sounds of running water and spiritual quotes before seeking sanctuary beneath the gargoyles and spires. Admire the splendid sacristy and chapels within, as well as the floor mosaics and brass items.", latitude: 37.8101, longitude: 144.9764, imageFilename: nil)
    }
}

