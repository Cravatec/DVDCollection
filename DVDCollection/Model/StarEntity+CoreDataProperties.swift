//
//  StarEntity+CoreDataProperties.swift
//  DVDCollection
//
//  Created by Sam on 03/09/2023.
//
//

import Foundation
import CoreData


extension StarEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StarEntity> {
        return NSFetchRequest<StarEntity>(entityName: "StarEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var type: String?
    @NSManaged public var text: String?

}

extension StarEntity : Identifiable {

}
