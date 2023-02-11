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
    }
    .inObjectScope(.transient)

    container.register(NoteDetailsViewModel.self) { _, id in
      NoteDetailsViewModel(noteId: id)
    }
    .inObjectScope(.transient)

    container.register(NoteCreateViewModel.self) { r in
      NoteCreateViewModel(ocrService: r.resolve(OCRService.self)!)
    }
    .inObjectScope(.transient)

    container.register(NotesGridViewModel.self) { _, id in
      NotesGridViewModel(noteGroupId: id)
    }
    .inObjectScope(.transient)

    container.register(NoteDetailsViewModel.self) { _, id in
      NoteDetailsViewModel(noteId: id)
    }
    .inObjectScope(.transient)
  }
}
