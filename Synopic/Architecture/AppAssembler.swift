//
//  AppAssembler.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Foundation
import Swinject

class AppAssembler {
    private let assembler: Assembler
  
    func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        return assembler.resolver.resolve(serviceType)
    }
  
    init() {
        self.assembler = Assembler([
            CoordinatorAssembly(),
            ServiceAssembly(),
            ViewModelAssembly(),
        ])
    }
}
