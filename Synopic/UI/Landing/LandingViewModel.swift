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

    self.onLoadGroup()
    self.onCreateGroup()
    self.onDeleteGroup()
    self.onViewGroup()
  }
  
  var lastTap = Date()

  // MARK: STATE
  @Published var searchText: String = .empty
  @Published var sections: [ViewSection] = []

  // MARK: EVENT
  let loadGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let createGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let deleteGroup: PassthroughSubject<Group, Never> = PassthroughSubject()
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
      .flatMap { self.summaries.deleteGroup(group: $0 ) }
      .sink(receiveValue: { [weak self] _ in
        self?.loadGroup.send()
      })
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
      .receive(on: .global(qos: .userInitiated))
      .flatMap { self.summaries.loadGroups() }
      .receive(on: .main)
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        print("LandingViewModel " + Thread.current.description)

        var noteKeys: [String] = []
        var noteGroups: [String: [Group]] = [:]
        
        for group in $0.sorted(by: { $0.lastEdited > $1.lastEdited }) {
          let key = group.lastEdited.title
          let value = group

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
