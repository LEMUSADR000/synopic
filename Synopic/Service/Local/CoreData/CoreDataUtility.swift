//
//  CoreDataUtility.swift
//  Synopic
//
//  Created by Adrian Lemus on 7/19/23.
//

import Combine
import CoreData

// MARK: - ManagedEntity

protocol ManagedEntity: NSFetchRequestResult {}

extension NSManagedObject {
  static var entityName: String {
    let nameMO = String(describing: Self.self)
    let suffixIndex = nameMO.index(nameMO.endIndex, offsetBy: -2)
    return String(nameMO[..<suffixIndex])
  }

  static func insertNew(in context: NSManagedObjectContext) -> Self? {
    return
      NSEntityDescription
<<<<<<< HEAD
        .insertNewObject(forEntityName: entityName, into: context) as? Self
=======
      .insertNewObject(forEntityName: entityName, into: context) as? Self
>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
  }
}

// MARK: - NSManagedObjectContext

extension NSManagedObjectContext {
<<<<<<< HEAD
=======

>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
  func configureAsReadOnlyContext() {
    automaticallyMergesChangesFromParent = true
    mergePolicy = NSRollbackMergePolicy
    undoManager = nil
    shouldDeleteInaccessibleFaults = true
  }

  func configureAsUpdateContext() {
    mergePolicy = NSOverwriteMergePolicy
    undoManager = nil
  }
}

// MARK: - Misc

extension NSSet {
  func toArray<T>(of type: T.Type) -> [T] {
    allObjects.compactMap { $0 as? T }
  }
}
