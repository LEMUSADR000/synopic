//
//  NoteCreateCoordinator.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//
import Combine
import CoreData
import Foundation
import Swinject
import VisionKit

protocol NoteCreateCoordinatorDelegate: AnyObject {
  func noteCreateCoordinatorDidComplete(_ source: NoteCreateCoordinator)
  func noteCreateCoordinatorDidCompleteWithNote(note: Note, _ source: NoteCreateCoordinator)
}

class NoteCreateCoordinator: ViewModel {
  private let resolver: Resolver
  private weak var delegate: NoteCreateCoordinatorDelegate?

  @Published private(set) var noteCreateViewModel: NoteCreateViewModel!

  @Published var toggleNavigation: Bool = false

  init(resolver: Resolver) {
    self.resolver = resolver
    self.noteCreateViewModel = resolver.resolve(NoteCreateViewModel.self)!
      .setup(delegate: self)
  }

  func setup(delegate: NoteCreateCoordinatorDelegate) -> Self {
    self.delegate = delegate
    return self
  }
}

// MARK: NoteCreateViewModelDelegate

extension NoteCreateCoordinator: NoteCreateViewModelDelegate {
  func noteCreateViewModelDidCancel(_ source: NoteCreateViewModel) {
    // TODO: Should we do anything else here?
    self.delegate?.noteCreateCoordinatorDidComplete(self)
  }

  func noteCreateViewModelDidProcessScan(_ source: NoteCreateViewModel) {
    // Is there a better way to do this?
    self.toggleNavigation = !self.toggleNavigation
  }

  func noteCreateViewModelFailedToGenerate(error: Error, _ source: NoteCreateViewModel) {
    // TODO: Should we do anything with error here?
    self.delegate?.noteCreateCoordinatorDidComplete(self)
  }

  func noteCreateViewModelGenerated(
    note: Note,
    _ source: NoteCreateViewModel
  ) {
    self.delegate?.noteCreateCoordinatorDidCompleteWithNote(note: note, self)
  }
}
