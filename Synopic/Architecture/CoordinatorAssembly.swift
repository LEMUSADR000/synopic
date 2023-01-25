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
        container.register(AppRootCoordinatorViewModel.self) { r in
            AppRootCoordinatorViewModel(resolver: r)
        }.inObjectScope(.container)
    }
}
