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

  init(resolver: Resolver) {
    self.resolver = resolver

    self.landingViewModel = self.resolver.resolve(LandingViewModel.self)!
      .setup(delegate: self)
  }

  private func showDetails(id: String?) {
    self.noteDetailsCoordinator = self.resolver.resolve(
      NoteGroupDetailsCoordinator.self,
      argument: id as String?
    )!
  }
}

// MARK: CameraViewModelDelegate

extension AppRootCoordinator: LandingViewModelDelegate {
  func landingViewModelDidTapCreateGroup(_ source: LandingViewModel) {
    self.showDetails(id: nil)
  }

  func landingViewModelDidTapViewGroup(
    noteGroupId: String,
    _ source: LandingViewModel
  ) { self.showDetails(id: noteGroupId) }
}
