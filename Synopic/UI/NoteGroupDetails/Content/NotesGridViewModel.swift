//
//  NotesGridViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Combine
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
  private weak var delegate: NotesGridViewModelDelegate?
  private var cancelBag: CancelBag!

  private let noteGroupId: String

  init(noteGroupId: String) { self.noteGroupId = noteGroupId }

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
  @Published var title: String = .empty

  @Published var author: String = .empty

  @Published var imageName: String? = nil

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

extension NotesGridViewModel {
  struct Note: Identifiable {
    let id: String
    var content: String
    var images: [CGImage]
  }
}
