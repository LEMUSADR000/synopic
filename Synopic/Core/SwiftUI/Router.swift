//
//  Router.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/14/23.
//

import Foundation

protocol CoordinatorRouter {
  func handleScopedNavigation(bundle: NavigationBundle?)
}

class Router: ObservableObject {
  @Published private(set) var bundle: NavigationBundle?
  func consumeNavigation() {
    self.bundle = nil
  }
  func navigate(to path: String, arguments: [String: Any]) {
    self.bundle = NavigationBundle(path: path, args: arguments)
  }
  func navigate(to path: String) {
    self.navigate(to: path, arguments: [:])
  }
}

// TODO: Should navigationbundle be typed?
struct NavigationBundle {
  let path: String
  let args: [String: Any]

  init(path: String) {
    self.path = path
    self.args = [:]
  }

  init(path: String, args: [String: Any]) {
    self.path = path
    self.args = args
  }
}
