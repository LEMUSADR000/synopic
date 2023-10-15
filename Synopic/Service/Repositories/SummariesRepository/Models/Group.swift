//
//  Group.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/15/23.
//

import Foundation
import SwiftUI

struct Group: Identifiable {
  let id: InternalObjectId?
  var lastEdited: Date
  var title: String
  var author: String
  var childCount: Int
<<<<<<< HEAD
  var imageURL: URL?
=======
  var imageName: String?
>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4

  init() {
    self.id = nil
    self.lastEdited = Date(timeIntervalSince1970: 0.0)
    self.title = ""
    self.author = ""
    self.childCount = 0
  }

  init(from entity: GroupEntityMO) {
    self.id = entity.objectID
    self.lastEdited = entity.lastEdited ?? Date(timeIntervalSince1970: 0.0)
    self.title = entity.title ?? ""
    self.author = entity.author ?? ""
    self.childCount = entity.child?.count ?? 0
    self.imageURL = makePath(rawName: entity.imageName)
  }

  init(
<<<<<<< HEAD
    id: InternalObjectId?, lastEdited: Date, title: String, author: String, childCount: Int,
=======
    id: InternalObjectId, lastEdited: Date, title: String, author: String, childCount: Int,
>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
    imageName: String?
  ) {
    self.id = id
    self.lastEdited = lastEdited
    self.title = title
    self.author = author
    self.childCount = childCount
    self.imageURL = makePath(rawName: imageName)
  }

  private func makePath(rawName: String?) -> URL? {
    if let imageName = rawName {
      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName)
    }

    return nil
  }

  mutating func updateImage(new: URL?) {
    guard let new = new, let old = imageURL
    else {
      return
    }

    try? FileManager.default.removeItem(at: old)

    do {
      let newURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(new.lastPathComponent))!
      try FileManager.default.moveItem(at: new, to: newURL)
      imageURL = newURL
    } catch {
      print("Failed to perform file transfer")
    }
  }
}
