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
  private let groupId: InternalObjectId
  private weak var delegate: NotesGridViewModelDelegate?
  private var cancelBag: CancelBag!

  init(summariesRepository: SummariesRepository, groupId: InternalObjectId) {
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
    self.onSaveGroup()
    self.loadNotes()

    self.summaries.groupForId(id: self.groupId)
      .tryMap { [weak self] value in
        self?.title = value?.title ?? .empty
        self?.author = value?.author ?? .empty
      }
      .sink(
        receiveCompletion: { print("completion: \($0)") },
        receiveValue: { print("received value: \($0)") }
      )
      .store(in: &self.cancelBag)
  }

  // MARK: STATE
  @Published var title: String = .empty
  @Published var author: String = .empty
  @Published var notes: LazyList<Note> = LazyList.empty

  // MARK: EVENT
  let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
  let viewNote: PassthroughSubject<InternalObjectId, Never> = PassthroughSubject()
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

  private func onSaveGroup() {
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
    self.summaries.loadNotes(parent: groupId)
      .receive(on: .main)
      .tryMap { [weak self] result in
        self?.notes = result
      }
      .sink()
      .store(in: &self.cancelBag)
  }

  static var notesGridViewModelPreview: NotesGridViewModel {
    let appAssembler = AppAssembler()
    let summaries = appAssembler.resolve(SummariesRepository.self)!

    let notesViewModel = NotesGridViewModel(
      summariesRepository: summaries,
      groupId: GroupEntityMO(context: NSManagedObjectContext(.mainQueue)).objectID
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
