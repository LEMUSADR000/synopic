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
  var imageURL: URL?

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
    id: InternalObjectId?, lastEdited: Date, title: String, author: String, childCount: Int,
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
    guard let new = new, let old = imageURL, new.lastPathComponent != old.lastPathComponent
    else {
      return
    }

    try? FileManager.default.removeItem(at: old)

    do {
      let newURL = makePath(rawName: new.lastPathComponent)!
      try FileManager.default.moveItem(at: new, to: newURL)
      imageURL = newURL
    } catch {
      print("Failed to perform file transfer \(error)")
    }
  }
}
