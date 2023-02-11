//
//  ViewSection.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/8/23.
//

import Foundation

class ViewSection: ViewModel {
  let dateCreated: Date

  @Published var items: [NoteGroup]

  init(
    created: Date,
    items: [NoteGroup]
  ) {
    self.dateCreated = created
    self.items = items
  }
}

extension ViewSection {
  var title: String {
    guard
      let day = Calendar.current
        .dateComponents([.day], from: self.dateCreated, to: .now).day
    else { return "N/A" }

    if day == 0 {
      return "Today"
    } else if day >= 7 {
      return "Last Week"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy"
      return formatter.string(from: self.dateCreated)
    }
  }
}
