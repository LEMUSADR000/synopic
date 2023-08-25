////
////  NoteGroup.swift
////  Synopic
////
////  Created by Adrian Lemus on 2/8/23.
////
//
//import Foundation
//import SwiftUI
//import CoreData
//
//struct NoteGroup: Identifiable {
//  let id: InternalObjectId
//  let created: Date
//  var title: String = .empty
//  var author: String = .empty
//  var imageName: String? = nil
//
//  init(id: InternalObjectId, created: Date) {
//    self.id = id
//    self.created = created
//  }
//
//  init(id: InternalObjectId, created: Date, title: String, author: String) {
//    self.id = id
//    self.created = created
//    self.title = title
//    self.author = author
//  }
//
//  init(
//    id: InternalObjectId,
//    created: Date,
//    title: String,
//    author: String,
//    imageName: String?
//  ) {
//    self.id = id
//    self.created = created
//    self.title = title
//    self.author = author
//    self.imageName = imageName
//  }
//}
//
//extension NoteGroup {
//  var image: Image? {
//    // TODO: Cache result of this if it appears to be an expensive operation
//    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
//    let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
//    let paths = NSSearchPathForDirectoriesInDomains(
//      nsDocumentDirectory,
//      nsUserDomainMask,
//      true
//    )
//
//    if let name = imageName, let dirPath = paths.first {
//      let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(name)
//      if let image = UIImage(contentsOfFile: imageURL.path) {
//        return Image(uiImage: image)
//      }
//    }
//
//    return nil
//  }
//}
