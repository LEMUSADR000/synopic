//
//  NoteGroupDetailsCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct NoteGroupDetailsCoordinatorView: View {
  @ObservedObject var coordinator: NoteGroupDetailsCoordinator

  init(coordinator: NoteGroupDetailsCoordinator) {
    self.coordinator = coordinator
  }

  var body: some View {
    NotesGridView(notesGridViewModel: self.coordinator.notesGridViewModel)
      .navigation(item: self.$coordinator.noteDetailsViewModel) { viewModel in
        NoteDetailsView(viewModel: viewModel)
      }
      .sheet(item: self.$coordinator.noteCreateCoordinator) { c in
        NavigationView {
          ZStack {
            Rectangle().foregroundColor(.black).edgesIgnoringSafeArea(.all)
            NoteCreateCoordinatorView(coordinator: c)
          }
        }
      }
  }
}

struct NoteGroupDetailsCoordinatorView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let coordinator = appAssembler.resolve(
    NoteGroupDetailsCoordinator.self,
    argument: nil as String?
  )!

  static var previews: some View {
    NoteGroupDetailsCoordinatorView(coordinator: coordinator)
  }
}
