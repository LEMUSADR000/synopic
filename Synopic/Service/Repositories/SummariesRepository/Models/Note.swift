//
//  Note.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/15/23.
//

import Foundation

struct Note: Identifiable {
  let id: InternalObjectId
  let created: Date
  let summary: String
  let groupId: String
}
