//
//  Group+CoreDataProperties.swift
//  Synopic
//
//  Created by Adrian Lemus on 8/9/23.
//
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var author: String
    @NSManaged public var imageName: String
    @NSManaged public var lastEdited: Date
    @NSManaged public var title: String
    @NSManaged public var child: NSOrderedSet?

}

// MARK: Generated accessors for child
extension Group {

    @objc(insertObject:inChildAtIndex:)
    @NSManaged public func insertIntoChild(_ value: Note, at idx: Int)

    @objc(removeObjectFromChildAtIndex:)
    @NSManaged public func removeFromChild(at idx: Int)

    @objc(insertChild:atIndexes:)
    @NSManaged public func insertIntoChild(_ values: [Note], at indexes: NSIndexSet)

    @objc(removeChildAtIndexes:)
    @NSManaged public func removeFromChild(at indexes: NSIndexSet)

    @objc(replaceObjectInChildAtIndex:withObject:)
    @NSManaged public func replaceChild(at idx: Int, with value: Note)

    @objc(replaceChildAtIndexes:withChild:)
    @NSManaged public func replaceChild(at indexes: NSIndexSet, with values: [Note])

    @objc(addChildObject:)
    @NSManaged public func addToChild(_ value: Note)

    @objc(removeChildObject:)
    @NSManaged public func removeFromChild(_ value: Note)

    @objc(addChild:)
    @NSManaged public func addToChild(_ values: NSOrderedSet)

    @objc(removeChild:)
    @NSManaged public func removeFromChild(_ values: NSOrderedSet)

}

extension Group : Identifiable {

}
