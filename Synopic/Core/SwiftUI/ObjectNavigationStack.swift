//
//  ObjectNavigationStack.swift
//  Synopic
//
//  Created by Adrian Lemus on 9/8/23.
//

import Foundation
import SwiftUI

struct ObjectNavigationStack<Content>: View where Content : View {
  @ObservedObject var path: Navigator
  let content: () -> Content
  
  var body: some View {
    NavigationStack(path: self.$path.path, root: self.content)
  }
}

final class Navigator: ObservableObject {
  typealias NavigationObject = AnyObject & Hashable & Equatable
  @Published fileprivate var path: NavigationPath = NavigationPath()
  @Published fileprivate var presentedItem: (any NavigationObject)?
  @Published fileprivate var coverItem: (any NavigationObject)?
  
  private var objects: [any NavigationObject] = []
  
  private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
  
  var last: (any NavigationObject)? {
    self.objects.last
  }
  
  func showSheet(_ object: some NavigationObject) {
    self.semaphore.wait() // TODO: Figure out if we actually need semaphores here
    self.presentedItem = object
    self.semaphore.signal()
  }
  
  func showFullScreenCover(_ object: some NavigationObject) {
    self.semaphore.wait() // TODO: Figure out if we actually need semaphores here
    self.coverItem = object
    self.semaphore.signal()
  }
  
  func append(_ object: some NavigationObject) {
    self.semaphore.wait()
    self.objects.append(object)
    self.path.append(object)
    self.semaphore.signal()
  }
  
  func removeLast() {
    self.semaphore.wait()
    self.objects.removeLast()
    self.path.removeLast()
    self.semaphore.signal()
  }
  
  @discardableResult
  func removeLast<Element : NavigationObject>(through graphObject: Element) -> Element? {
    self.semaphore.wait()
    var removeCount: Int = 0
    defer {
      self.path.removeLast(removeCount)
      self.semaphore.signal()
    }
    
    while let object = self.objects.popLast() {
      removeCount = removeCount + 1
      if graphObject === object {
        return graphObject
      }
    }
    return nil
  }
  
  @discardableResult
  func removeLast(through clause: (any NavigationObject) -> Bool) -> (any NavigationObject)? {
    self.semaphore.wait()
    var removeCount: Int = 0
    defer {
      self.path.removeLast(removeCount)
      self.semaphore.signal()
    }
    
    while let object = self.objects.popLast() {
      removeCount = removeCount + 1
      if clause(object) {
        return object
      }
    }
    return nil
  }
}

