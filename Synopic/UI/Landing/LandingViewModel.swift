//
//  LandingViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import Combine
import CoreData
import Foundation
import SwiftUI

private let defaultDate = Date(timeIntervalSince1970: 0.0)

protocol LandingViewModelDelegate: AnyObject {
  func landingViewModelDidTapViewGroup(
    group: Group?,
    _ source: LandingViewModel
  )
}

class LandingViewModel: ViewModel {
  private let summaries: SummariesRepository
  private weak var delegate: LandingViewModelDelegate?
  private var cancelBag: CancelBag!

  init(summaries: SummariesRepository) {
    self.summaries = summaries
  }

  func setup(delegate: LandingViewModelDelegate) -> Self {
    self.delegate = delegate
    self.bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()

    self.onLoadGroup()
    self.onCreateGroup()
    self.onDeleteGroup()
    self.onViewGroup()

    self.loadGroup.send()
  }

  var lastTap = Date()

  // MARK: STATE

  @Published var searchText: String = .empty
  @Published var sections: [ViewSection] = []

  // MARK: EVENT

  let loadGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let createGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let deleteGroup: PassthroughSubject<IndexPath, Never> = PassthroughSubject()
  let viewGroup: PassthroughSubject<Group, Never> = PassthroughSubject()

  private func onCreateGroup() {
    self.createGroup
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.landingViewModelDidTapViewGroup(group: nil, self)
      })
      .store(in: &self.cancelBag)
  }

  private func onDeleteGroup() {
    self.deleteGroup
      .receive(on: .main)
      .flatMap { [weak self] path in
        guard let self = self else {
          return Just<IndexPath?>(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        let group = self.sections[path.section].items[path.row]
        return self.summaries.deleteGroup(group: group)
          .flatMap { _ in self.summaries.loadGroups() }
          .map { _ in path }
          .map(Optional.some)
          .eraseToAnyPublisher()
      }
      .sink(
        receiveValue: { [weak self] path in
          guard let self = self, let path = path else { return }
          self.sections[path.section].items.remove(at: path.row)
          if self.sections[path.section].items.count == 0 {
            _ = withAnimation(.easeOut) {
              self.sections.remove(at: path.section)
            }
          }
        },
        failure: { error in
          print("failed to delete \(error.localizedDescription)")
        }
      )
      .store(in: &self.cancelBag)
  }

  private func onViewGroup() {
    self.viewGroup
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.landingViewModelDidTapViewGroup(group: $0, self)
      })
      .store(in: &self.cancelBag)
  }

  private func onLoadGroup() {
    self.loadGroup
      .receive(on: .main)
      .flatMap { self.summaries.loadGroups() }
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }

        if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
          let fileList = try! FileManager.default.contentsOfDirectory(atPath: path)
          for file in fileList {
            print("\(path)/\(file)")
          }
        }

        var noteKeys: [String] = []
        var noteGroups: [String: [Group]] = [:]

        // TODO: Sort these on fetch from DB
        for group in $0.sorted(by: { $0.lastEdited > $1.lastEdited }) {
          let key = group.lastEdited.title
          let value = group

          if var list = noteGroups[key] {
            list.append(value)
            noteGroups[key] = list
          } else {
            noteGroups[key] = [value]
            noteKeys.append(key)
          }
        }

        var sections: [ViewSection] = []
        for key in noteKeys {
          sections.append(ViewSection(title: key, items: noteGroups[key]!))
        }
        withAnimation {
          self.sections = sections
        }
      })
      .store(in: &self.cancelBag)
  }

  // Function to generate a random CGFloat between 0 and 1
  private static var randomCGFloat: CGFloat {
    CGFloat.random(in: 0 ... 1)
  }

  // Function to generate a random pastel color
  static func randomPastelColor() -> Color {
    var randomColor = UIColor(red: self.randomCGFloat, green: self.randomCGFloat, blue: self.randomCGFloat, alpha: 1.0)

    // Saturate the color by 10%
    randomColor = randomColor.saturated(by: 0.1)

    // Mix with white
    randomColor = randomColor.mixed(with: .white)

    return Color(randomColor)
  }
}

extension Date {
  var title: String {
    guard
      let day = Calendar.current
      .dateComponents([.day], from: self, to: .now).day
    else { return "--" }

    if day == 0 {
      return "Today"
    } else if day > 0 && day < 1 {
      return "Yesterday"
    } else if day < 7 {
      return "Previous 7 Days"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy"
      return formatter.string(from: self)
    }
  }
}
