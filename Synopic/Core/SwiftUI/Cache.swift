//
//  ThreadSafeCache.swift
//  Synopic
//
//  Created by Adrian Lemus on 3/8/23.
//

import Combine
import Foundation

actor Cache<Key: Hashable, Value> {
  init() {
    self.cache = [Key: Value]()
    self.valueChanged = CurrentValueSubject<[Key: Value], Never>(self.cache)
  }

  private var cache: [Key: Value]

  var value: [Key: Value] {
    get async {
      return cache
    }
  }

  func getValue(forKey key: Key) async -> Value? {
    return cache[key]
  }

  // Should we separate logic for set with value changed?
  @discardableResult func setValue(_ value: Value, forKey key: Key) async -> Value {
    self.cache[key] = value
    self.valueChanged.send(self.cache)
    return self.cache[key]!
  }

  @discardableResult func removeValue(forKey key: Key) async -> Value? {
    let value = cache.removeValue(forKey: key)
    self.valueChanged.send(self.cache)
    return value
  }

  func addAll(_ dict: [Key: Value]) async {
    for (key, value) in dict {
      cache[key] = value
    }
    self.valueChanged.send(self.cache)
  }

  func removeAll() async {
    cache.removeAll()
    self.valueChanged.send(self.cache)
  }

  private nonisolated let valueChanged:
    CurrentValueSubject<[Key: Value], Never>
  nonisolated var publisher: AnyPublisher<[Key: Value], Never> {
    valueChanged.eraseToAnyPublisher()
  }
}
