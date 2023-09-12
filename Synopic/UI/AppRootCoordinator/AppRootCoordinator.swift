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
  let navigator: Navigator
  
  @Published private(set) var landingViewModel: LandingViewModel!

  init(resolver: Resolver) {
    self.resolver = resolver
    self.navigator = self.resolver.resolve(Navigator.self)!

    self.landingViewModel = self.resolver.resolve(LandingViewModel.self)!
      .setup(delegate: self)
  }
}

// MARK: CameraViewModelDelegate

extension AppRootCoordinator: LandingViewModelDelegate {
  func landingViewModelDidTapViewGroup(
    group: Group?,
    _ source: LandingViewModel
  ) {
    self.navigator.append(
      self.resolver.resolve(NoteGroupDetailsCoordinator.self, argument: group)!
    )
  }
}
