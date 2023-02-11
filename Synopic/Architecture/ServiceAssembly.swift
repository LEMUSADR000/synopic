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
    container.register(OCRService.self) { _ in
      OCRServiceImpl()
    }.inObjectScope(.container)

    // MARK: Repositories
    container.register(SummariesRepository.self) { r in
      SummariesRepositoryImpl(chatGptApiService: r.resolve(ChatGPTService.self)!)
    }.inObjectScope(.container)

    // MARK: API
    container.register(ChatGPTService.self) { _ in
      // TODO: Find where we will be getting token from!
      ChatGPTServiceImpl(token: "NONE")
    }.inObjectScope(.transient)
  }
}
