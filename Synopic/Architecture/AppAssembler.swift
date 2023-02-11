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

  func resolve<Service, Arg1>(_ serviceType: Service.Type, argument: Arg1)
    -> Service?
  { return assembler.resolver.resolve(serviceType, argument: argument) }

  init() {
    self.assembler = Assembler([
      CoordinatorAssembly(), ServiceAssembly(), ViewModelAssembly(),
    ])
  }
}
