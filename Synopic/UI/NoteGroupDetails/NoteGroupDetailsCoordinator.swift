//
//  NoteDetailsCoordinator.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Combine
import CoreData
import Foundation
import SwiftUI
import Swinject
import UIKit

protocol NoteGroupDetailsCoordinatorDelegate: AnyObject {
  func noteGroupDetailsCoordinatorDidModifyGroup(_ source: NoteGroupDetailsCoordinator)
}

class NoteGroupDetailsCoordinator: ViewModel {
  private let resolver: Resolver

  @Published private(set) var notesGridViewModel: NotesGridViewModel!

  @Published var noteCreateCoordinator: NoteCreateCoordinator?
  @Published var cameraViewModel: CameraViewModel?

  private weak var delegate: NoteGroupDetailsCoordinatorDelegate?

  private var group: Group

  var theme: Color {
    self.group.usableColor
  }

  init(resolver: Resolver, group: Group) {
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
  func notesGridViewModelDidDeleteGroup(_ source: NotesGridViewModel) {
    self.delegate?.noteGroupDetailsCoordinatorDidModifyGroup(self)
  }

  func notesGridViewModelDidTapTakePicture(_ source: NotesGridViewModel) {
    self.cameraViewModel = self.resolver.resolve(
      CameraViewModel.self
    )!.setup(delegate: self)
  }

  func notesGridViewModelDidCreateGroup(newGroup: Group, _ source: NotesGridViewModel) {
    self.delegate?.noteGroupDetailsCoordinatorDidModifyGroup(self)
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
