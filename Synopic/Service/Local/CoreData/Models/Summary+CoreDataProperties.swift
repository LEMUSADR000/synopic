//
//  Summary+CoreDataProperties.swift
//  Synopic
//
//  Created by Adrian Lemus on 7/19/23.
//
//

import Foundation
import CoreData


extension Summary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Summary> {
        return NSFetchRequest<Summary>(entityName: "Summary")
    }

    @NSManaged public var created: Date?
    @NSManaged public var summary: String?
    @NSManaged public var child: Note?

}

extension Summary : Identifiable {

}
