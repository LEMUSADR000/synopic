//
//  ViewSection.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/8/23.
//

import Foundation

class ViewSection: ViewModel {
  let title: String

  @Published var items: [Group]

  init(title: String, items: [Group]) {
    self.title = title
    self.items = items
  }
}
