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
        container.register(CameraManager.self) { r in
            CameraManager()
        }.inObjectScope(.container)

        container.register(CameraServiceProtocol.self) { r in
            CameraService(cameraManager: r.resolve(CameraManager.self)!)
        }.inObjectScope(.container)
    }
}
