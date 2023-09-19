//
//  NoteDetailsCoordinator.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Combine
import CoreData
import Foundation
import Swinject

public class NoteGroupDetailsCoordinator: ViewModel {
  private let resolver: Resolver

  @Published private(set) var notesGridViewModel: NotesGridViewModel!

  @Published var noteCreateCoordinator: NoteCreateCoordinator?

  private var group: Group?

  init(resolver: Resolver, group: Group?) {
    self.resolver = resolver
    self.group = group

    self.notesGridViewModel = self.resolver.resolve(
      NotesGridViewModel.self,
      argument: group
    )!
    .setup(delegate: self)
  }
}

// MARK: NotesGridViewModelDelegate

extension NoteGroupDetailsCoordinator: NotesGridViewModelDelegate {
  func notesGridViewModelDidTapViewNote(
    id: InternalObjectId,
    _ source: NotesGridViewModel
  ) {

  }

  func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel) {
    self.noteCreateCoordinator = self.resolver.resolve(
      NoteCreateCoordinator.self
    )!.setup(delegate: self)
  }
}

// MARK: NoteCreateCoordinatorDelegate

extension NoteGroupDetailsCoordinator: NoteCreateCoordinatorDelegate {
  func noteCreateCoordinatorDidCompleteWithNote(note: Note, _ source: NoteCreateCoordinator) {
    Task { @MainActor [weak self] in
      self?.notesGridViewModel.noteCreated.send(note)
      self?.noteCreateCoordinator = nil
    }
  }
  
  func noteCreateCoordinatorDidComplete(_ source: NoteCreateCoordinator) {
    Task { @MainActor [weak self] in
      self?.noteCreateCoordinator = nil
    }
  }
}
