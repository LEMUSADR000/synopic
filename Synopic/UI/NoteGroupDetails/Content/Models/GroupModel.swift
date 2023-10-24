//
//  GroupModel.swift
//  Synopic
//
//  Created by adrian.lemus on 10/23/23.
//

import Foundation
import SwiftUI

class GroupModel: ViewModel {
  init(title: String, author: String, _ notes: [Note] = [], theme: Color) {
    self.title = title
    self.author = author
    self.notes = notes
    self.theme = theme
  }

  @Published var title: String = .empty
  @Published var author: String = .empty
  @Published var notes: [Note] = []
  let theme: Color
}
