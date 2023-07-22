//
//  Group+CoreDataProperties.swift
//  Synopic
//
//  Created by Adrian Lemus on 7/19/23.
//
//

import Foundation
import CoreData


extension Group {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Group> {
        return NSFetchRequest<Group>(entityName: "Group")
    }

    @NSManaged public var lastEdited: Date?
    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var imageName: String?
    @NSManaged public var parent: NSOrderedSet?

}

// MARK: Generated accessors for parent
extension Group {

    @objc(insertObject:inParentAtIndex:)
    @NSManaged public func insertIntoParent(_ value: Note, at idx: Int)

    @objc(removeObjectFromParentAtIndex:)
    @NSManaged public func removeFromParent(at idx: Int)

    @objc(insertParent:atIndexes:)
    @NSManaged public func insertIntoParent(_ values: [Note], at indexes: NSIndexSet)

    @objc(removeParentAtIndexes:)
    @NSManaged public func removeFromParent(at indexes: NSIndexSet)

    @objc(replaceObjectInParentAtIndex:withObject:)
    @NSManaged public func replaceParent(at idx: Int, with value: Note)

    @objc(replaceParentAtIndexes:withParent:)
    @NSManaged public func replaceParent(at indexes: NSIndexSet, with values: [Note])

    @objc(addParentObject:)
    @NSManaged public func addToParent(_ value: Note)

    @objc(removeParentObject:)
    @NSManaged public func removeFromParent(_ value: Note)

    @objc(addParent:)
    @NSManaged public func addToParent(_ values: NSOrderedSet)

    @objc(removeParent:)
    @NSManaged public func removeFromParent(_ values: NSOrderedSet)

}

extension Group : Identifiable {

}
