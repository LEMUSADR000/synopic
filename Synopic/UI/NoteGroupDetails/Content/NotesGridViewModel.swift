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

  func notesGridViewModelDidTapViewNote(
    id: InternalObjectId,
    _ source: NotesGridViewModel
  )

  func notesGridViewModelDidRequireGroupCreation(_ source: NotesGridViewModel)
}

class NotesGridViewModel: ViewModel {
  private let summaries: SummariesRepository
  private let camera: CameraService
  private var group: Group?
  private weak var delegate: NotesGridViewModelDelegate?
  private var cancelBag: CancelBag!

  init(summariesRepository: SummariesRepository, cameraService: CameraService, group: Group?) {
    self.summaries = summariesRepository
    self.camera = cameraService
    self.group = group

    self.model = GroupModel(
      imagePath: self.group?.imageName,
      title: self.group?.title ?? .empty,
      author: self.group?.author ?? .empty
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
    self.onViewNote()
    self.loadNotes()
    self.onNoteCreated()
  }

  // MARK: STATE

  @Published var model: GroupModel
  @Published var selected: Int = 0

  // MARK: EVENT

  let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewNote: PassthroughSubject<InternalObjectId, Never> = PassthroughSubject()
  let noteCreated: PassthroughSubject<Note, Never> = PassthroughSubject()
  let takeCoverPicture: PassthroughSubject<Void, Never> = PassthroughSubject()

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
        let imagePath = model.imagePath

        if title.isEmpty && author.isEmpty && notes.isEmpty, let unwrapped = self.group {
          return self.summaries.deleteGroup(group: unwrapped)
            .map(Optional.some)
            .eraseToAnyPublisher()
        }

        var toUpdate = self.group ?? Group()
        if toUpdate.title == title && toUpdate.author == author
          && toUpdate.childCount == notes.count
        {
          return Just<Group?>(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        toUpdate.imageName = imagePath
        toUpdate.title = title
        toUpdate.author = author

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

  private func onViewNote() {
    self.viewNote
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.delegate?.notesGridViewModelDidTapViewNote(id: $0, self)
      })
      .store(in: &self.cancelBag)
  }
  
  private func onTakeCoverPhoto() {
    self.takeCoverPicture
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.camera.start()
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
    init(imagePath: String? = nil, title: String, author: String, _ notes: [Note] = []) {
      self.imagePath = imagePath
      self.title = title
      self.author = author
      self.notes = notes
    }

    @Published var imagePath: String?
    @Published var title: String = .empty
    @Published var author: String = .empty
    @Published var notes: [Note] = []
  }

  static var notesGridViewModelPreview: NotesGridViewModel {
    let appAssembler = AppAssembler()
    let summaries = appAssembler.resolve(SummariesRepository.self)!
    let camera = appAssembler.resolve(CameraService.self)!

    let notesViewModel = NotesGridViewModel(
      summariesRepository: summaries,
      cameraService: camera,
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

enum Ordering {
  case grid
  case list
  case carousel
}
