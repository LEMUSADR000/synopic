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
    id: ObjectIdentifier,
    _ source: NotesGridViewModel
  )
}

public class NotesGridViewModel: ViewModel {
  private let summaries: SummariesRepository
  private let groupId: ObjectIdentifier
  private weak var delegate: NotesGridViewModelDelegate?
  private var cancelBag: CancelBag!

  init(summariesRepository: SummariesRepository, groupId: ObjectIdentifier) {
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
    self.onSaveNote()
    self.loadNotes()

    self.summaries.groups
      .prefix(1)
      .sink { [weak self] value in
        var title: String = .empty
        var author: String = .empty

        if let id = self?.groupId, let group = value[id] {
          title = group.title
          author = group.author
        }

        self?.title = title
        self?.author = author
      }
      .store(in: &self.cancelBag)
  }

  // MARK: STATE
  @Published var title: String = .empty
  @Published var author: String = .empty
  @Published var notes: [Note] = []

  // MARK: EVENT
  let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewNote: PassthroughSubject<ObjectIdentifier, Never> = PassthroughSubject()
  let saveChanges: PassthroughSubject<Void, Never> = PassthroughSubject()

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

  private func onSaveNote() {
    self.saveChanges
      .withLatestFrom(
        self.$title,
        self.$author
      )
      .setFailureType(to: Error.self)
      .flatMapLatest { title, author -> AnyPublisher<Any?, Error> in
        Future<Any?, Error> { promise in
          Task { [weak self] in
            guard let self = self else { return }
            do {
              let updated = try await self.summaries
                .updateGroup(id: self.groupId, title: title, author: author)
              promise(.success(nil))
            }
            catch {
              promise(.failure(error))
            }
          }
        }
        .eraseToAnyPublisher()
      }
      .sink()
      .store(in: &self.cancelBag)
  }

  private func loadNotes() {
    self.summaries.loadNotes()
      .map { [weak self] in
        if let groupId = self?.groupId {
          return $0[groupId] ?? []
        }
        
        return []
      }
      .receive(on: .main)
      .sink(receiveValue: { [weak self] value in
        self?.notes = value
      })
      .store(in: &self.cancelBag)
  }

  static var notesGridViewModelPreview: NotesGridViewModel {
    let appAssembler = AppAssembler()
    let summaries = appAssembler.resolve(SummariesRepository.self)!

    let notesViewModel = NotesGridViewModel(
      summariesRepository: summaries,
      groupId: ObjectIdentifier(UUID.self)
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
