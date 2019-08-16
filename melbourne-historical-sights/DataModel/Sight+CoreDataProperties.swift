//
//  Sight+CoreDataProperties.swift
//  melbourne-historical-sights
//
//  Created by fit5140 on 16/8/19.
//  Copyright © 2019 Ian Estraikh. All rights reserved.
//
//

import Foundation
import CoreData


extension Sight {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sight> {
        return NSFetchRequest<Sight>(entityName: "Sight")
    }

    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var imageFilename: String?

}
