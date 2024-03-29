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
      LandingViewModel(summaries: r.resolve(SummariesRepository.self)!)
    }
    .inObjectScope(.transient)

    container.register(NoteCreateViewModel.self) { r in
      NoteCreateViewModel(
        ocrService: r.resolve(OCRService.self)!,
        summariesRepository: r.resolve(SummariesRepository.self)!
      )
    }
    .inObjectScope(.transient)

    container.register(NotesGridViewModel.self) { r, group in
      NotesGridViewModel(
        summariesRepository: r.resolve(SummariesRepository.self)!,
        group: group
      )
    }
    .inObjectScope(.transient)

    container.register(CameraViewModel.self) { r in
      CameraViewModel(
        camera: r.resolve(CameraService.self)!
      )
    }
    .inObjectScope(.transient)
  }
}
