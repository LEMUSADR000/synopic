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
  func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel)
  func notesGridViewModelDidTapTakePicture(_ source: NotesGridViewModel)

  func notesGridViewModelDidTapViewNote(
    id: InternalObjectId,
    _ source: NotesGridViewModel
  )

  func notesGridViewModelDidRequireGroupCreation(_ source: NotesGridViewModel)
}

class NotesGridViewModel: ViewModel {
  private let summaries: SummariesRepository
  private var group: Group?
  private weak var delegate: NotesGridViewModelDelegate?
  private var cancelBag: CancelBag!

  init(summariesRepository: SummariesRepository, group: Group?) {
    self.summaries = summariesRepository
    self.group = group

    self.model = GroupModel(
      title: self.group?.title ?? .empty,
      author: self.group?.author ?? .empty,
      theme: self.group?.usableColor ?? Color.generateRandomPastelColor()
    )
  }

  func setup(delegate: NotesGridViewModelDelegate) -> Self {
    self.delegate = delegate
    self.bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()
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

  let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
  let takePicture: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewNote: PassthroughSubject<InternalObjectId, Never> = PassthroughSubject()
  let noteCreated: PassthroughSubject<Note, Never> = PassthroughSubject()

  func saveGroup() {
    Just(1)
      .withLatestFrom(self.$model)
      .setFailureType(to: Error.self)
      .flatMapLatest { [weak self] model -> AnyPublisher<Group?, Error> in
        guard let self = self else {
          return Just<Group?>(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        let title = model.title
        let author = model.author
        let notes = model.notes

        if title.isEmpty && author.isEmpty && notes.isEmpty, let unwrapped = self.group {
          return self.summaries.deleteGroup(group: unwrapped)
            .map(Optional.some)
            .eraseToAnyPublisher()
        }

        var toUpdate = self.group ?? Group()

        // No update required
        if toUpdate.title == title && toUpdate.author == author
          && toUpdate.childCount == notes.count
        {
          return Just<Group?>(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        toUpdate.title = title
        toUpdate.author = author

//        for i in 0 ... 100 {
//          var new = Group()
//          new.title = "Title \(i)"
//          new.author = "Author \(i)"
//
//          self.summaries.updateGroup(group: new, notes: [])
//        }

        return self.summaries.updateGroup(group: toUpdate, notes: notes)
          .map(Optional.some)
          .eraseToAnyPublisher()
      }
      .sink(receiveValue: { [weak self] group in
        guard let self = self else { return }

        if group != nil {
          self.delegate?.notesGridViewModelDidRequireGroupCreation(self)
        }
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
      .compactMap { _ in self.group?.id }
      .flatMap { self.summaries.loadNotes(parent: $0) }
      .sink(receiveValue: { [weak self] result in
        self?.model.notes = result
      })
      .store(in: &self.cancelBag)
  }

  class GroupModel: ViewModel {
    init(title: String, author: String, _ notes: [Note] = [], theme: Color) {
      self.title = title
      self.author = author
      self.notes = notes
      self.theme = theme
    }

    @Published var title: String = .empty
    @Published var author: String = .empty
    @Published var notes: [Note] = []
    let theme: Color
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
