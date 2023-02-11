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
  private let ocrService: OCRService
  private weak var delegate: LandingViewModelDelegate?
  private var cancelBag: CancelBag!

  init(
    ocrService: OCRService
  ) {
    self.ocrService = ocrService

    let today = Date()
    let data = [
      today, Calendar.current.date(byAdding: .day, value: -1, to: today)!,
      Calendar.current.date(byAdding: .day, value: -7, to: today)!,
    ]

    self.sections = [
      ViewSection(
        created: data[0],
        items: [
          NoteGroup(created: data[0], title: "Lion's King", author: "Author 1"),
          NoteGroup(
            created: data[0].adding(hours: -2),
            title: "Enders Game",
            author: "Author 2"
          ),
          NoteGroup(
            created: data[0].adding(hours: -4),
            title: "Star Wars",
            author: "Author 3"
          ),
        ]
      ),
      ViewSection(
        created: data[1],
        items: [
          NoteGroup(created: data[1], title: "Lion's King", author: "Author 1"),
          NoteGroup(
            created: data[1].adding(hours: -2),
            title: "Enders Game",
            author: "Author 2"
          ),
        ]
      ),
      ViewSection(
        created: data[2],
        items: [
          NoteGroup(created: data[2], title: "Lion's King", author: "Author 1")
        ]
      ),
    ]
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
  }

  // MARK: STATE
  @Published var searchText: String = .empty
  @Published var sections: [ViewSection] = []

  // MARK: EVENT
  let createGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewGroup: PassthroughSubject<String, Never> = PassthroughSubject()

  private func onCreateGroup() {
    self.createGroup
      .sink(receiveValue: { [weak self] in guard let self = self else { return }
        self.delegate?.landingViewModelDidTapCreateGroup(self)
      })
      .store(in: &self.cancelBag)
  }

  private func onViewGroup() {
    self.viewGroup
      .sink(receiveValue: { [weak self] in guard let self = self else { return }
        self.delegate?.landingViewModelDidTapViewGroup(noteGroupId: $0, self)
      })
      .store(in: &self.cancelBag)
  }
}
