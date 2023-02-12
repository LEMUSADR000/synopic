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
    }
    .inObjectScope(.container)

    container.register(NoteCreateCoordinator.self) { r in
      NoteCreateCoordinator(resolver: r)
    }
    .inObjectScope(.transient)

    container.register(NoteGroupDetailsCoordinator.self) { r, id in
      NoteGroupDetailsCoordinator(resolver: r, groupId: id)
    }
    .inObjectScope(.transient)
  }
}
