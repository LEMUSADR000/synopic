//
//  AppRootCoordinatorViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Foundation
import Combine
import Swinject

class AppRootCoordinator: ViewModel {
    private let resolver: Resolver
    
    @Published private(set) var landingViewModel: LandingViewModel!
    
    @Published var noteDetailsCoordinator: NoteDetailsCoordinator?
  
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.landingViewModel = self.resolver.resolve(LandingViewModel.self)!.setup(delegate: self)
    }
}

// MARK: CameraViewModelDelegate

extension AppRootCoordinator: LandingViewModelDelegate {
    func landingViewModelDidTapCreateGroup(_ source: LandingViewModel) {
        self.noteDetailsCoordinator = self.resolver.resolve(NoteDetailsCoordinator.self)!.setup(delegate: self)
    }
}

// MARK: NoteDetailsViewModelDelegate

extension AppRootCoordinator: NoteDetailsCoordinatorDelegate {
    func noteDetailsCoordinatorDidTapCreateNote(_ source: NoteDetailsCoordinator) {
        // nothing yet
    }
}
