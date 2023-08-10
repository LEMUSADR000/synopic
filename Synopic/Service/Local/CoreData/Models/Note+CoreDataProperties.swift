//
//  Note+CoreDataProperties.swift
//  Synopic
//
//  Created by Adrian Lemus on 8/9/23.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var created: Date
    @NSManaged public var summary: String
    @NSManaged public var parent: Group?

}

extension Note : Identifiable {

}
