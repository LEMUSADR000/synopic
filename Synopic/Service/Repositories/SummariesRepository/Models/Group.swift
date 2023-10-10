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
  
  var image : Image? {
    if let file = imageName {
      return Image.fromFile(from: file)
    }
    return nil
  }

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
  }

  init(
    id: InternalObjectId?, lastEdited: Date, title: String, author: String, childCount: Int,
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
