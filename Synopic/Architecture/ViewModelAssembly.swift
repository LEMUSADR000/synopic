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
        container.register(LandingViewModel.self) { r in
            LandingViewModel(ocrService: r.resolve(OCRService.self)!)
        }.inObjectScope(.transient)
        
        container.register(ScanDocumentsViewModel.self) { r in
            ScanDocumentsViewModel(ocrService: r.resolve(OCRService.self)!)
        }.inObjectScope(.transient)
    }
}
