//
//  NotesGridViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Combine
import CombineExt
import Foundation
import UIKit

protocol NotesGridViewModelDelegate: AnyObject {
  func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel)
  func notesGridViewModelDidTapViewNote(
    id: String,
    _ source: NotesGridViewModel
  )
}

public class NotesGridViewModel: ViewModel {
  private let summaries: SummariesRepository
  private let groupId: String?
  private weak var delegate: NotesGridViewModelDelegate?
  private var cancelBag: CancelBag!

  init(summariesRepository: SummariesRepository, groupId: String?) {
    self.summaries = summariesRepository
    self.groupId = groupId
  }

  func setup(delegate: NotesGridViewModelDelegate) -> Self {
    self.delegate = delegate
    bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()
    self.onCreateNote()
    self.onViewNote()
  }

  // MARK: STATE
  var title: AnyPublisher<String, Never> {
    self.summaries.groups
      .map { value in
        value[self.groupId!]?.title ?? ""
      }
      .eraseToAnyPublisher()
  }

  var author: AnyPublisher<String, Never> {
    self.summaries.groups.map { value in value[self.groupId!]?.author ?? "" }
      .eraseToAnyPublisher()
  }

  @Published var notes: [Note] = []

  // MARK: EVENT
  let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()

  let viewNote: PassthroughSubject<String, Never> = PassthroughSubject()

  private func onCreateNote() {
    self.createNote
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.notesGridViewModelDidTapCreateNote(self)
      })
      .store(in: &self.cancelBag)
  }

  private func onViewNote() {
    self.viewNote
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.notesGridViewModelDidTapViewNote(id: $0, self)
      })
      .store(in: &self.cancelBag)
  }
}
