//
//  LandingViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import Combine
import Foundation
import SwiftUI

protocol LandingViewModelDelegate: AnyObject {
  func landingViewModelDidTapCreateGroup(_ source: LandingViewModel)
  func landingViewModelDidTapViewGroup(
    noteGroupId: String,
    _ source: LandingViewModel
  )
}

public class LandingViewModel: ViewModel {
  private let summaries: SummariesRepository
  private weak var delegate: LandingViewModelDelegate?
  private var cancelBag: CancelBag!

  init(summaries: SummariesRepository) {
    self.summaries = summaries
  }

  func setup(delegate: LandingViewModelDelegate) -> Self {
    self.delegate = delegate
    bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()

    self.onCreateGroup()
    self.onViewGroup()
    self.onNewGroup()
  }

  // MARK: STATE
  @Published var searchText: String = .empty
  @Published var sections: [ViewSection] = []

  // MARK: EVENT
  let createGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewGroup: PassthroughSubject<String, Never> = PassthroughSubject()

  private func onCreateGroup() {
    self.createGroup
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.landingViewModelDidTapCreateGroup(self)
      })
      .store(in: &self.cancelBag)
  }

  private func onViewGroup() {
    self.viewGroup
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.landingViewModelDidTapViewGroup(noteGroupId: $0, self)
      })
      .store(in: &self.cancelBag)
  }

  private func onNewGroup() {
    self.summaries.loadGroups()
      .receive(on: .main)
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }

        var noteKeys: [String] = []
        var noteGroups: [String: [NoteGroup]] = [:]
        for group in $0.values.sorted(by: { $0.lastEdited > $1.lastEdited }) {
          let key = group.lastEdited.title
          let value = NoteGroup(
            id: group.id,
            created: group.lastEdited,
            title: group.title,
            author: group.author
          )

          if var list = noteGroups[key] {
            list.append(value)
            noteGroups[key] = list
          }
          else {
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
}

extension Date {
  var title: String {
    guard
      let day = Calendar.current
        .dateComponents([.day], from: self, to: .now).day
    else { return "--" }

    if day == 0 {
      return "Today"
    }
    else if day > 0 && day < 1 {
      return "Yesterday"
    }
    else if day < 7 {
      return "Previous 7 Days"
    }
    else {
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy"
      return formatter.string(from: self)
    }
  }
}
