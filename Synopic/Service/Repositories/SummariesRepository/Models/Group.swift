//
//  Group.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/15/23.
//

import Foundation
import SwiftUI
import UIKit

struct Group: Identifiable, Hashable {
  let id: InternalObjectId?
  var lastEdited: Date
  var title: String
  var author: String
  var childCount: Int
  private let backsplash: CGColor

  var usableColor: Color {
    Color(cgColor: backsplash)
  }

  var codableTheme: Data? {
    try? JSONEncoder().encode(CodableColor(cgColor: backsplash))
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  init() {
    self.id = nil
    self.lastEdited = Date(timeIntervalSince1970: 0.0)
    self.title = ""
    self.author = ""
    self.childCount = 0
    self.backsplash = CGColor.generateRandomPastelColor()
  }

  init(from entity: GroupEntityMO) {
    self.id = entity.objectID
    self.lastEdited = entity.lastEdited ?? Date(timeIntervalSince1970: 0.0)
    self.title = entity.title ?? ""
    self.author = entity.author ?? ""
    self.childCount = entity.child?.count ?? 0

    if let colorData = entity.theme, let storedCGColor = (try? JSONDecoder()
      .decode(CodableColor.self, from: colorData))?.cgColor
    {
      self.backsplash = storedCGColor
    } else {
      self.backsplash = CGColor.generateRandomPastelColor()
    }
  }

  init(
    id: InternalObjectId?, lastEdited: Date, title: String, author: String, childCount: Int,
    theme: Color?
  ) {
    self.id = id
    self.lastEdited = lastEdited
    self.title = title
    self.author = author
    self.childCount = childCount
    self.backsplash = theme?.cgColor ?? CGColor.generateRandomPastelColor()
  }

  init(title: String, author: String) {
    self.id = nil
    self.lastEdited = Date.now
    self.title = title
    self.author = author
    self.childCount = 0
    self.backsplash = CGColor.generateRandomPastelColor()
  }

  // TODO: Figure out what kind of images we actually care about
//  private func makePath(rawName: String?) -> URL? {
//    if let imageName = rawName {
//      return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(imageName)
//    }
//
//    return nil
//  }
//
//  mutating func updateImage(new: URL?) {
//    guard let new = new, let old = imageURL, new.lastPathComponent != old.lastPathComponent
//    else {
//      return
//    }
//
//    try? FileManager.default.removeItem(at: old)
//
//    do {
//      let newURL = makePath(rawName: new.lastPathComponent)!
//      try FileManager.default.moveItem(at: new, to: newURL)
//      imageURL = newURL
//    } catch {
//      print("Failed to perform file transfer \(error)")
//    }
//  }
}
