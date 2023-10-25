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
    group: Group,
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
    self.onViewGroup()
    self.summaries.loadGroups()
  }

  var lastTap = Date()

  // MARK: STATE

  @Published var searchText: String = .empty
  @Published var sections: [ViewSection] = [] {
    didSet {
      self.sectionCount = self.sections.count
    }
  }

  @Published var sectionCount = 0

  // MARK: EVENT

  let loadGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let createGroup: PassthroughSubject<GroupModel, Never> = PassthroughSubject()
  let deleteGroup: PassthroughSubject<Group, Never> = PassthroughSubject()
  let viewGroup: PassthroughSubject<Group?, Never> = PassthroughSubject()

  private func onViewGroup() {
    self.viewGroup
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        // It's okay to create empty Group since it will be used to save a new one anyway
        let group = $0 ?? Group()
        self.delegate?.landingViewModelDidTapViewGroup(group: group, self)
      })
      .store(in: &self.cancelBag)
  }

  private func onLoadGroup() {
    self.summaries.groups
      .delay(for: 0.05, scheduler: RunLoop.main)
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }

        withAnimation {
          self.sections.removeAll(keepingCapacity: true)
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

        for key in noteKeys {
          withAnimation {
            self.sections.append(ViewSection(title: key, items: noteGroups[key]!))
          }
        }
      })
      .store(in: &self.cancelBag)
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
