//
//  LazyList.swift
//  Synopic
//
//  Created by Adrian Lemus on 7/19/23.
//

import Foundation

struct LazyList<T> {
<<<<<<< HEAD
=======

>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
  typealias Access = (Int) throws -> T?
  private let access: Access
  private let useCache: Bool
  private var cache = Cache()

  let count: Int

  init(count: Int, useCache: Bool, _ access: @escaping Access) {
    self.count = count
    self.useCache = useCache
    self.access = access
  }

  func element(at index: Int) throws -> T {
    guard useCache else {
      return try get(at: index)
    }
    return try cache.sync { elements in
      if let element = elements[index] {
        return element
      }
      let element = try get(at: index)
      elements[index] = element
      return element
    }
  }

  private func get(at index: Int) throws -> T {
    guard let element = try access(index) else {
      throw Error.elementIsNil(index: index)
    }
    return element
  }

  static var empty: Self {
    return .init(count: 0, useCache: false) { index in
      throw Error.elementIsNil(index: index)
    }
  }
}

<<<<<<< HEAD
private extension LazyList {
  class Cache {
=======
extension LazyList {
  fileprivate class Cache {

>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
    private var elements = [Int: T]()

    func sync(_ access: (inout [Int: T]) throws -> T) throws -> T {
      guard Thread.isMainThread else {
        var result: T!
        try DispatchQueue.main.sync {
          result = try access(&elements)
        }
        return result
      }
      return try access(&elements)
    }
  }
}

extension LazyList: Sequence {
<<<<<<< HEAD
=======

>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
  enum Error: LocalizedError {
    case elementIsNil(index: Int)

    var localizedDescription: String {
      switch self {
      case let .elementIsNil(index):
        return "Element at index \(index) is nil"
      }
    }
  }

  struct Iterator: IteratorProtocol {
    typealias Element = T
    private var index = -1
    private var list: LazyList<Element>

    init(list: LazyList<Element>) {
      self.list = list
    }

    mutating func next() -> Element? {
      index += 1
      guard index < list.count else {
        return nil
      }
      do {
        return try list.element(at: index)
      } catch _ {
        return nil
      }
    }
  }

  func makeIterator() -> Iterator {
    .init(list: self)
  }

  var underestimatedCount: Int { count }
}

extension LazyList: RandomAccessCollection {
<<<<<<< HEAD
  typealias Index = Int
  var startIndex: Index { 0 }
  var endIndex: Index { count }

  subscript(index: Index) -> Iterator.Element {
    do {
      return try element(at: index)
    } catch {
      fatalError("\(error)")
    }
  }

=======

  typealias Index = Int
  var startIndex: Index { 0 }
  var endIndex: Index { count }

  subscript(index: Index) -> Iterator.Element {
    do {
      return try element(at: index)
    } catch let error {
      fatalError("\(error)")
    }
  }

>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
  public func index(after index: Index) -> Index {
    return index + 1
  }

  public func index(before index: Index) -> Index {
    return index - 1
  }
}

extension LazyList: Equatable where T: Equatable {
  static func == (lhs: LazyList<T>, rhs: LazyList<T>) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return Swift.zip(lhs, rhs).first(where: { $0 != $1 }) == nil
  }
}

extension LazyList: CustomStringConvertible {
  var description: String {
<<<<<<< HEAD
    let elements = reduce(
      "")
    { str, element in
      if str.count == 0 {
        return "\(element)"
      }
      return str + ", \(element)"
    }
=======
    let elements = self.reduce(
      "",
      { str, element in
        if str.count == 0 {
          return "\(element)"
        }
        return str + ", \(element)"
      })
>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
    return "LazyList<[\(elements)]>"
  }
}

extension RandomAccessCollection {
  var lazyList: LazyList<Element> {
<<<<<<< HEAD
    return .init(count: count, useCache: false) {
=======
    return .init(count: self.count, useCache: false) {
>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
      guard $0 < self.count else { return nil }
      let index = self.index(self.startIndex, offsetBy: $0)
      return self[index]
    }
  }
}
