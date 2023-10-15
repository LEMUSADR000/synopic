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
      imagePath: self.group?.imageURL,
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
    self.onTakePicture()
    self.onViewNote()
    self.loadNotes()
    self.onNoteCreated()
    self.onImageSelected()
  }

  // MARK: STATE

  @Published var model: GroupModel
  @Published var selected: Int = 0

  // MARK: EVENT

  let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
  let takePicture: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewNote: PassthroughSubject<InternalObjectId, Never> = PassthroughSubject()
  let noteCreated: PassthroughSubject<Note, Never> = PassthroughSubject()
  let imageSelected: PassthroughSubject<CIImage, Never> = PassthroughSubject()

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

        if title.isEmpty && author.isEmpty && notes.isEmpty && imagePath == nil, let unwrapped = self.group {
          return self.summaries.deleteGroup(group: unwrapped)
            .map(Optional.some)
            .eraseToAnyPublisher()
        }

        var toUpdate = self.group ?? Group()

        // No update required
        if toUpdate.title == title && toUpdate.author == author
          && toUpdate.imageURL == model.imagePath
          && toUpdate.childCount == notes.count
        {
          return Just<Group?>(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        toUpdate.updateImage(new: imagePath)
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

  private func onImageSelected() {
    self.imageSelected
      .subscribe(on: .global(qos: .userInteractive))
      .sink(receiveValue: { [weak self] image in
        guard let self = self else { return }

        do {
          if let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) {
            let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).png")
            try CIContext().writePNGRepresentation(of: image, to: destinationURL, format: .RGBA8, colorSpace: colorSpace)
            withAnimation {
              self.model.imagePath = destinationURL
            }
          }
        } catch {
          // TODO: How should we handle this error?
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
    init(imagePath: URL? = nil, title: String, author: String, _ notes: [Note] = []) {
      self.imagePath = imagePath
      self.title = title
      self.author = author
      self.notes = notes
    }

    @Published var imagePath: URL?
    @Published var title: String = .empty
    @Published var author: String = .empty
    @Published var notes: [Note] = []
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
