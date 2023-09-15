//
//  NotesGridViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Combine
import CombineExt
import CoreData
import Foundation
import UIKit

protocol NotesGridViewModelDelegate: AnyObject {
  func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel)
  func notesGridViewModelDidTapViewNote(
    id: InternalObjectId,
    _ source: NotesGridViewModel
  )
}

public class NotesGridViewModel: ViewModel {
  private let summaries: SummariesRepository
  private var group: Group
  private weak var delegate: NotesGridViewModelDelegate?
  private var cancelBag: CancelBag!

  init(summariesRepository: SummariesRepository, group: Group?) {
    self.summaries = summariesRepository
    self.group = group ?? Group()
    self.title = self.group.title
    self.author = self.group.author
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
    self.loadNotes()
  }

  // MARK: STATE
  @Published var title: String = .empty
  @Published var author: String = .empty
  @Published var notes: [Note] = []

  // MARK: EVENT
  let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewNote: PassthroughSubject<InternalObjectId, Never> = PassthroughSubject()
//  let saveChanges: PassthroughSubject<Void, Never> = PassthroughSubject()

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

  func saveGroup() async {
    self.group.author = self.author
    self.group.title = self.title
    _ = try? await self.summaries.updateGroup(group: self.group, notes: self.notes)
  }

  private func loadNotes() {
    if let groupId = self.group.id {
      self.summaries.loadNotes(parent: groupId)
        .receive(on: .main)
        .tryMap { [weak self] result in
          self?.notes = result
        }
        .sink()
        .store(in: &self.cancelBag)
    }
  }

  static var notesGridViewModelPreview: NotesGridViewModel {
    let appAssembler = AppAssembler()
    let summaries = appAssembler.resolve(SummariesRepository.self)!

    let notesViewModel = NotesGridViewModel(
      summariesRepository: summaries,
      group: Group()
    )
//
//    notesViewModel.notes = [
//      Note(
//        id: UUID().uuidString,
//        created: Date(),
//        summary:
//          "\u{2022} point number one of this should be short\n\u{2022} point number two of this should be short\n\u{2022} point number three of this should be short\n\u{2022} point number four of this should be short\n\u{2022} point number five of this should be short\n\u{2022} point number six of this should be short",
//        groupId: "test"
//      ),
//      Note(
//        id: UUID().uuidString,
//        created: Date(),
//        summary:
//          "\u{2022} point number one of this should be short\n\u{2022} point number two of this should be short\n\u{2022} point number three of this should be short",
//        groupId: "test"
//      ),
//      Note(
//        id: UUID().uuidString,
//        created: Date(),
//        summary:
//          "\u{2022} point number one of this should be short\n\u{2022} point number two of this should be short\n\u{2022} point number three of this should be short",
//        groupId: "test"
//      ),
//      Note(
//        id: UUID().uuidString,
//        created: Date(),
//        summary:
//          "\u{2022} point number one of this should be short\n\u{2022} point number two of this should be short\n\u{2022} point number three of this should be short",
//        groupId: "test"
//      ),
//      Note(
//        id: UUID().uuidString,
//        created: Date(),
//        summary: "\u{2022} point number two of this should be short",
//        groupId: "test"
//      ),
//      Note(
//        id: UUID().uuidString,
//        created: Date(),
//        summary: "\u{2022} point number three of this should be short",
//        groupId: "test"
//      ),
//    ]

    return notesViewModel
  }
}
