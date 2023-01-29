//
//  CoordinatorAssembly.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Foundation
import Swinject

class CoordinatorAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AppRootCoordinator.self) { r in
            AppRootCoordinator(resolver: r)
        }.inObjectScope(.container)
        
        container.register(ScanDocumentsCoordinator.self) { r in
            ScanDocumentsCoordinator(resolver: r)
        }.inObjectScope(.container)
    }
}
