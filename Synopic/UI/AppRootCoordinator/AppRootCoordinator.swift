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
    
    @Published var scanDocumentsCoordinator: ScanDocumentsCoordinator?
  
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.landingViewModel = self.resolver.resolve(LandingViewModel.self)!.setup(delegate: self)
    }
}

// MARK: CameraViewModelDelegate

extension AppRootCoordinator: LandingViewModelDelegate {
    func landingViewModelDidTapOpenSheet(_ source: LandingViewModel) {
        self.scanDocumentsCoordinator = self.resolver.resolve(ScanDocumentsCoordinator.self)!.setup(delegate: self)
    }
}

// MARK: ScanDocumentsCoordinatorDelegate

extension AppRootCoordinator: ScanDocumentsCoordinatorDelegate {
    func scanDocumentsViewModelDidCancel(_ source: ScanDocumentsCoordinator) {
        self.scanDocumentsCoordinator = nil
    }
    
    func scanDocumentsViewModelDidSave(_ source: ScanDocumentsCoordinator) {
        self.scanDocumentsCoordinator = nil
    }
}
