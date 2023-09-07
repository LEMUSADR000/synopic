//
//  NavigationBundle.swift
//  Synopic
//
//  Created by Adrian Lemus on 9/1/23.
//

import Foundation

// TODO: Make this more flexible in order to handle different payloads
class PathBundle: Hashable {
  let path: String
  let model: any ViewModel
  
  static func == (lhs: PathBundle, rhs: PathBundle) -> Bool {
    return lhs.path == rhs.path
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(path)
  }
  
  init(path: String, model: any ViewModel) {
    self.path = path
    self.model = model
  }
}
