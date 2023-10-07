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
  var imageName: String?

  init() {
    self.id = nil
    self.lastEdited = Date.init(timeIntervalSince1970: 0.0)
    self.title = ""
    self.author = ""
    self.childCount = 0
  }

  init(from entity: GroupEntityMO) {
    self.id = entity.objectID
    self.lastEdited = entity.lastEdited ?? Date.init(timeIntervalSince1970: 0.0)
    self.title = entity.title ?? ""
    self.author = entity.author ?? ""
    self.childCount = entity.child?.count ?? 0
  }

  init(
    id: InternalObjectId, lastEdited: Date, title: String, author: String, childCount: Int,
    imageName: String?
  ) {
    self.id = id
    self.lastEdited = lastEdited
    self.title = title
    self.author = author
    self.imageName = imageName
    self.childCount = childCount
  }
}

// MARK: Extensions

extension Group {
  var image: Image? {
    // TODO: Cache result of this if it appears to be an expensive operation
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(
      nsDocumentDirectory,
      nsUserDomainMask,
      true
    )

    if let name = imageName, let dirPath = paths.first {
      let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(name)
      if let image = UIImage(contentsOfFile: imageURL.path) {
        return Image(uiImage: image)
      }
    }

    return nil
  }
}
