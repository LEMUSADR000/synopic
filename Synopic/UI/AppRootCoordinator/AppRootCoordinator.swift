//
//  AppRootCoordinatorViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Combine
import CoreData
import Foundation
import Swinject

class AppRootCoordinator: ViewModel {
  private let resolver: Resolver

  @Published private(set) var landingViewModel: LandingViewModel!

  @Published var noteGroupDetailsCoordinator: NoteGroupDetailsCoordinator?

  init(resolver: Resolver) {
    self.resolver = resolver

    self.landingViewModel = self.resolver.resolve(LandingViewModel.self)!
      .setup(delegate: self)
  }
}

// MARK: CameraViewModelDelegate

extension AppRootCoordinator: LandingViewModelDelegate {
  func landingViewModelDidTapViewGroup(
    group: Group,
    _ source: LandingViewModel
  ) {
    self.noteGroupDetailsCoordinator = self.resolver.resolve(
      NoteGroupDetailsCoordinator.self,
      argument: group
    )!.setup(delegate: self)
  }
}

extension AppRootCoordinator: NoteGroupDetailsCoordinatorDelegate {
  func noteGroupDetailsCoordinatorDidModifyGroup(_ source: NoteGroupDetailsCoordinator) {
    self.noteGroupDetailsCoordinator = nil
    self.landingViewModel.loadGroup.send()
  }
}
