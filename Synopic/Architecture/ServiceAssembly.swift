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
        container.register(OCRServiceProtocol.self) { _ in
            // TODO: Bind data layer to this for persisting scans & endpoint results!
            OCRService()
        }.inObjectScope(.container)
    }
}
