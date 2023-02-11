//
//  NoteDetailsView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/8/23.
//

import Foundation

protocol NoteDetailsViewModelDelegate: AnyObject {
  func noteDetailsDidExit(_ source: NoteDetailsViewModel)
}

class NoteDetailsViewModel: ViewModel {
  private var cancelBag: CancelBag!
  private weak var delegate: NoteDetailsViewModelDelegate?
  private let noteId: String

  init(noteId: String) {
    self.noteId = noteId
  }

  func setup(delegate: NoteDetailsViewModelDelegate) -> Self {
    self.delegate = delegate
    bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()
  }
}
