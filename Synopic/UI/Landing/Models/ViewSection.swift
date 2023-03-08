//
//  ViewSection.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/8/23.
//

import Foundation

class ViewSection: ViewModel {
  let title: String

  @Published var items: [NoteGroup]

  init(title: String, items: [NoteGroup]) {
    self.title = title
    self.items = items
  }
}
