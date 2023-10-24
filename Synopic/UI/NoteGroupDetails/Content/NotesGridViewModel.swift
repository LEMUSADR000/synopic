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
import SwiftUI
import UIKit

protocol NotesGridViewModelDelegate: AnyObject {
  func notesGridViewModelDidDeleteGroup(deleted: Group, _ source: NotesGridViewModel)
  func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel)
  func notesGridViewModelDidTapTakePicture(_ source: NotesGridViewModel)
  func notesGridViewModelDidTapViewNote(
    id: InternalObjectId,
    _ source: NotesGridViewModel
  )
}

class NotesGridViewModel: ViewModel {
  private let summaries: SummariesRepository
  private var group: Group
  private weak var delegate: NotesGridViewModelDelegate?
  private var cancelBag: CancelBag!

  var theme: Color {
    self.group.usableColor
  }

  let canDelete: Bool

  init(summariesRepository: SummariesRepository, group: Group) {
    self.summaries = summariesRepository
    self.group = group
    self.canDelete = group.id != nil

    self.model = GroupModel(
      title: self.group.title,
      author: self.group.author,
      theme: self.group.usableColor
    )
  }

  func setup(delegate: NotesGridViewModelDelegate) -> Self {
    self.delegate = delegate
    self.bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()
    self.onGroupDelete()
    self.onCreateNote()
    self.onTakePicture()
    self.onViewNote()
    self.loadNotes()
    self.onNoteCreated()
  }

  // MARK: STATE

  @Published var model: GroupModel
  @Published var selected: Int = 0

  // MARK: EVENT

  let deleteGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let confirmDeleteGroup: PassthroughSubject<Void, Never> = PassthroughSubject()
  let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
  let takePicture: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewNote: PassthroughSubject<InternalObjectId, Never> = PassthroughSubject()
  let noteCreated: PassthroughSubject<Note, Never> = PassthroughSubject()

  func saveGroup() {
    Just(1)
      .withLatestFrom(self.$model)
      .setFailureType(to: Error.self)
      .flatMapLatest { [weak self] model -> AnyPublisher<Void, Error> in
        guard let self = self else {
          return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        let title = model.title
        let author = model.author
        let notes = model.notes

        if title.isEmpty, author.isEmpty, notes.isEmpty, self.group.id != nil {
          return self.summaries.deleteGroup(group: self.group)
            .map { _ in () }
            .eraseToAnyPublisher()
        }

        var toUpdate = self.group

        // No update required
        if toUpdate.title == title, toUpdate.author == author,
           toUpdate.childCount == notes.count
        {
          return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        toUpdate.title = title
        toUpdate.author = author

        return self.summaries.updateGroup(group: toUpdate, notes: notes)
          .map { _ in () }
          .eraseToAnyPublisher()
      }
      .sink()
      .store(in: &self.cancelBag)
  }

  private func onGroupDelete() {
    self.deleteGroup
      .receive(on: .main)
      .flatMap {
        self.summaries.deleteGroup(group: self.group)
          .map { _ in () }
          .eraseToAnyPublisher()
      }
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.notesGridViewModelDidDeleteGroup(deleted: self.group, self)
      })
      .store(in: &self.cancelBag)
  }

  private func onNoteCreated() {
    self.noteCreated
      .delay(for: 0.35, scheduler: RunLoop.main)
      .sink(receiveValue: { [weak self] note in
        guard let self = self else { return }
        withAnimation {
          self.model.notes.append(note)
          self.selected = self.model.notes.count - 1
        }
      })
      .store(in: &self.cancelBag)
  }

  private func onCreateNote() {
    self.createNote
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.notesGridViewModelDidTapCreateNote(self)
      })
      .store(in: &self.cancelBag)
  }

  private func onTakePicture() {
    self.takePicture
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.notesGridViewModelDidTapTakePicture(self)
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

  private func loadNotes() {
    Just<Int>(1)
      .compactMap { _ in self.group.id }
      .flatMap { self.summaries.loadNotes(parent: $0) }
      .sink(receiveValue: { [weak self] result in
        self?.model.notes = result
      })
      .store(in: &self.cancelBag)
  }

  static var notesGridViewModelPreview: NotesGridViewModel {
    let appAssembler = AppAssembler()
    let summaries = appAssembler.resolve(SummariesRepository.self)!

    let notesViewModel = NotesGridViewModel(
      summariesRepository: summaries,
      group: Group()
    )

    return notesViewModel
  }
}

enum Ordering {
  case grid
  case list
  case carousel
}
