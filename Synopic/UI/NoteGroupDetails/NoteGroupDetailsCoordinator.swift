//
//  NoteDetailsCoordinator.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Combine
import Foundation
import Swinject

public class NoteGroupDetailsCoordinator: ViewModel {
  private let resolver: Resolver

  @Published private(set) var notesGridViewModel: NotesGridViewModel!

  @Published var noteCreateCoordinator: NoteCreateCoordinator?

  private var noteGroupId: String

  init(resolver: Resolver, groupId: String?) {
    self.resolver = resolver

    // TODO: Figure out how to better handle this so that if a user taps create we only generate a new NoteGroup object if they make changes to said group
    let uuid = groupId ?? UUID().uuidString
    self.noteGroupId = uuid

    self.notesGridViewModel = self.resolver.resolve(
      NotesGridViewModel.self,
      argument: uuid
    )!
    .setup(delegate: self)
  }
}

// MARK: NotesGridViewModelDelegate

extension NoteGroupDetailsCoordinator: NotesGridViewModelDelegate {
  func notesGridViewModelDidTapViewNote(
    id: String,
    _ source: NotesGridViewModel
  ) {

  }

  func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel) {
    self.noteCreateCoordinator = self.resolver.resolve(
      NoteCreateCoordinator.self
    )!
    .setup(delegate: self)
  }
}

// MARK: NoteCreateCoordinatorDelegate

extension NoteGroupDetailsCoordinator: NoteCreateCoordinatorDelegate {
  func noteCreateCoordinatorDidComplete(_ source: NoteCreateCoordinator) {
    self.noteCreateCoordinator = nil
  }
}
