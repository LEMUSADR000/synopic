//
//  AppRootCoordinatorViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Combine
import Foundation
import Swinject
import CoreData

class AppRootCoordinator: ViewModel {
  private let resolver: Resolver

  @Published private(set) var landingViewModel: LandingViewModel!

  @Published var noteDetailsCoordinator: NoteGroupDetailsCoordinator?

  init(resolver: Resolver) {
    self.resolver = resolver

    self.landingViewModel = self.resolver.resolve(LandingViewModel.self)!
      .setup(delegate: self)
  }

  private func showDetails(id: String) {
    self.noteDetailsCoordinator = self.resolver.resolve(
      NoteGroupDetailsCoordinator.self,
      argument: id
    )!
  }
}

// MARK: CameraViewModelDelegate

extension AppRootCoordinator: LandingViewModelDelegate {
  func landingViewModelDidTapViewGroup(
    noteGroupId: InternalObjectId,
    _ source: LandingViewModel
  ) {
    self.noteDetailsCoordinator = self.resolver.resolve(
      NoteGroupDetailsCoordinator.self,
      argument: noteGroupId
    )!
  }
}
