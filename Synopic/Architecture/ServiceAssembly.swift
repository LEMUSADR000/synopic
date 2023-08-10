//
//  ServiceAssembly.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Foundation
import Swinject

class ServiceAssembly: Assembly {
  func assemble(container: Container) {
    // MARK: Local
    container.register(OCRService.self) { _ in OCRServiceImpl() }
      .inObjectScope(.container)
    
    container.register(PersistentStore.self) { _ in CoreDataStack(version: CoreDataStack.Version.actual) }
      .inObjectScope(.container)

    // MARK: Repositories
    container.register(SummariesRepository.self) { r in
      SummariesRepositoryImpl(
        chatGptApiService: r.resolve(ChatGPTService.self)!,
        persistentStore: r.resolve(PersistentStore.self)!
      )
    }
    .inObjectScope(.container)

    // MARK: API
    container.register(ChatGPTService.self) { _ in
      // TODO: Find where we will be getting token from!
      ChatGPTServiceImpl(
        token: "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"
      )
    }
    .inObjectScope(.transient)
  }
}
