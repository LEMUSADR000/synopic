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

    container.register(NoteCreateViewModel.self) { r, id in
      NoteCreateViewModel(
        ocrService: r.resolve(OCRService.self)!,
        summariesRepository: r.resolve(SummariesRepository.self)!,
        groupId: id
      )
    }
    .inObjectScope(.transient)

    container.register(NotesGridViewModel.self) { r, id in
      NotesGridViewModel(
        summariesRepository: r.resolve(SummariesRepository.self)!,
        groupId: id
      )
    }
    .inObjectScope(.transient)
  }
}
