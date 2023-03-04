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

//extension ViewSection {
//  var title: String {
//    guard
//      let day = Calendar.current
//        .dateComponents([.day], from: self.dateCreated, to: .now).day
//    else { return "--" }
//
//    if day == 0 {
//      return "Today"
//    }
//    else if day > 0 && day < 7 {
//      return "Yesterday"
//    }
//    else if day >= 7 {
//      return "Previous 7 Days"
//    }
//    else {
//      let formatter = DateFormatter()
//      formatter.dateFormat = "yyyy"
//      return formatter.string(from: self.dateCreated)
//    }
//  }
//}
