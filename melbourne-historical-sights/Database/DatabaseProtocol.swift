//
//  DatabaseProtocol.swift
//  melbourne-historical-sights
//
//  Created by fit5140 on 16/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//

enum DatabaseChange {
    case add
    case remove
    case update
}

protocol DatabaseListener: AnyObject {
    func onSightListChange(change: DatabaseChange, sights: [Sight])
}

protocol DatabaseProtocol: AnyObject {
    func addSight(name: String, desc: String, latitude: Double, longitude: Double, imageFilename: String?, color: Int16, glyphimage: Int16) -> Sight
    func addImageFilenameToSight(imageFilename: String, sight: Sight) -> Bool
    func deleteSight(sight: Sight)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func saveContext()
}

