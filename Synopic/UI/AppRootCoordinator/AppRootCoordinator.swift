//
//  AppRootCoordinatorViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Combine
import Foundation
import Swinject

class AppRootCoordinator: ViewModel {
  private let resolver: Resolver

  @Published private(set) var landingViewModel: LandingViewModel!

  @Published var noteDetailsCoordinator: NoteGroupDetailsCoordinator?

  init(
    resolver: Resolver
  ) {
    self.resolver = resolver

    self.landingViewModel = self.resolver.resolve(LandingViewModel.self)!
      .setup(delegate: self)
  }
}

// MARK: CameraViewModelDelegate

extension AppRootCoordinator: LandingViewModelDelegate {
  func landingViewModelDidTapCreateGroup(_ source: LandingViewModel) {
    self.noteDetailsCoordinator = self.resolver.resolve(
      NoteGroupDetailsCoordinator.self,
      argument: nil as String?
    )!
  }

  func landingViewModelDidTapViewGroup(
    noteGroupId: String,
    _ source: LandingViewModel
  ) {
    self.noteDetailsCoordinator = self.resolver.resolve(
      NoteGroupDetailsCoordinator.self,
      argument: noteGroupId as String?
    )!
  }
}

// MARK: NoteDetailsViewModelDelegate

//extension AppRootCoordinator: NoteGroupDetailsCoordinatorDelegate {
//
//}
