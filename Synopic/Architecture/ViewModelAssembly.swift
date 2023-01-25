//
//  ViewModelAssembly.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Foundation
import Swinject

class ViewModelAssembly: Assembly {
    func assemble(container: Container) {
        container.register(CameraViewModel.self) { r in
            CameraViewModel(cameraService: r.resolve(CameraServiceProtocol.self)!)
        }.inObjectScope(.transient)
    }
}
