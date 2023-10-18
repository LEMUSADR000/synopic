//
//  NoteDetailsCoordinator.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import UIKit
import Combine
import CoreData
import Foundation
import Swinject

protocol NoteGroupDetailsCoordinatorDelegate: AnyObject {
  func noteGroupDetailsCoordinatorDidCreateGroup(_ source: NoteGroupDetailsCoordinator)
}

class NoteGroupDetailsCoordinator: ViewModel {
  private let resolver: Resolver

  @Published private(set) var notesGridViewModel: NotesGridViewModel!

  @Published var noteCreateCoordinator: NoteCreateCoordinator?
  @Published var cameraViewModel: CameraViewModel?

  private weak var delegate: NoteGroupDetailsCoordinatorDelegate?

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

  func setup(delegate: NoteGroupDetailsCoordinatorDelegate) -> Self {
    self.delegate = delegate
    return self
  }
}

// MARK: NotesGridViewModelDelegate

extension NoteGroupDetailsCoordinator: NotesGridViewModelDelegate {
  func notesGridViewModelDidTapTakePicture(_ source: NotesGridViewModel) {
    self.cameraViewModel = self.resolver.resolve(
      CameraViewModel.self
    )!.setup(delegate: self)
  }

  func notesGridViewModelDidRequireGroupCreation(_ source: NotesGridViewModel) {
    self.delegate?.noteGroupDetailsCoordinatorDidCreateGroup(self)
  }

  func notesGridViewModelDidTapViewNote(
    id: InternalObjectId,
    _ source: NotesGridViewModel
  ) {}

  func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel) {
    self.noteCreateCoordinator = self.resolver.resolve(
      NoteCreateCoordinator.self
    )!.setup(delegate: self)
  }
}

// MARK: NoteCreateCoordinatorDelegate

extension NoteGroupDetailsCoordinator: NoteCreateCoordinatorDelegate {
  func noteCreateCoordinatorDidCompleteWithNote(note: Note, _ source: NoteCreateCoordinator) {
    self.notesGridViewModel.noteCreated.send(note)
    self.noteCreateCoordinator = nil
  }

  func noteCreateCoordinatorDidComplete(_ source: NoteCreateCoordinator) {
    self.noteCreateCoordinator = nil
  }
}

// MARK: NotesGridViewModelDelegate

extension NoteGroupDetailsCoordinator: CameraViewModelDelegate {
  func cameraViewDidSelectImage(image: CIImage, _ source: CameraViewModel) {
//    self.notesGridViewModel.imageSelected.send(image)
//    self.cameraViewModel = nil
  }
}
