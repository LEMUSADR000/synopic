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
  let viewNote: PassthroughSubject<String, Never> = PassthroughSubject()
  let saveNote: PassthroughSubject<Void, Never> = PassthroughSubject()

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
    self.saveNote
      .withLatestFrom(
        self.$title,
        self.$author
      )
      .setFailureType(to: Error.self)
      .flatMapLatest { title, author -> AnyPublisher<Any?, Error> in
        Future<Any?, Error> { promise in
          Task { [weak self] in
            do {
              try await self!.summaries
                .updateGroup(id: self!.groupId, title: title, author: author)
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
      .last()
      .sink { [weak self] value in
        if let id = self?.groupId, let notes = value[id] {
          self?.notes = notes
        }
      }
      .store(in: &self.cancelBag)
  }
}
