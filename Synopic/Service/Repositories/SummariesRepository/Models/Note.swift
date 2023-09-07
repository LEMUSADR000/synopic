//
//  Note.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/15/23.
//

import Foundation

struct Note: Identifiable {
  let id: InternalObjectId?
  let created: Date
  let summary: String
  
  init(id: InternalObjectId) {
    self.id = id
    self.created = Date.init(timeIntervalSince1970: 0.0)
    self.summary = ""
  }
  
  init(from entity: NoteEntityMO) {
    self.id = entity.objectID
    self.created = entity.created ?? Date.init(timeIntervalSince1970: 0.0)
    self.summary = entity.summary ?? ""
  }
  
  init(id: InternalObjectId?, created: Date, summary: String) {
    self.id = id
    self.created = created
    self.summary = summary
  }
}
