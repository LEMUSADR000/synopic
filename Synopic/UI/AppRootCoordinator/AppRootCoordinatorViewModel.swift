//
//  AppRootCoordinatorViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Foundation
import Combine
import Swinject

class AppRootCoordinatorViewModel: ViewModel {
    private let resolver: Resolver
    
    @Published private(set) var cameraViewModel: CameraViewModel!
  
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.cameraViewModel = self.resolver.resolve(CameraViewModel.self)!.setpup(delegate: self)
    }
}

// MARK: CameraViewModelDelegate

extension AppRootCoordinatorViewModel: CameraViewModelDelegate {
    func cameraViewModelDidTapCapture(_ source: CameraViewModel) {
    }
}
