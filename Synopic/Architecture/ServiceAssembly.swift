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
    // MARK: - Local

    container.register(OCRService.self) { _ in OCRServiceImpl() }
      .inObjectScope(.weak)

    container.register(PersistentStore.self) { _ in
      CoreDataStack(version: CoreDataStack.Version.actual)
    }
    .inObjectScope(.container)

    // MARK: - Repositories

    container.register(SummariesRepository.self) { r in
      SummariesRepositoryImpl(
        chatGptApiService: r.resolve(ChatGPTService.self)!,
        persistentStore: r.resolve(PersistentStore.self)!
      )
    }
    .inObjectScope(.container)

    // MARK: - API

    container.register(ChatGPTService.self) { _ in
      ChatGPTServiceImpl()
    }
    .inObjectScope(.transient)

    container.register(CameraManager.self) { _ in
      CameraManager()
    }.inObjectScope(.container)

    container.register(CameraService.self) { r in
      CameraServiceImpl(cameraManager: r.resolve(CameraManager.self)!)
    }.inObjectScope(.transient)
  }
}
