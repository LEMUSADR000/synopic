//
//  NoteGroupDetailsCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//
import SwiftUI

struct NoteGroupDetailsCoordinatorView: View {
  static let path = "NoteGroupDetailsCoordinatorView"

  @StateObject var coordinator: NoteGroupDetailsCoordinator

  var body: some View {
    NotesGridView(notesGridViewModel: self.coordinator.notesGridViewModel)
      .fullScreenCover(item: self.$coordinator.noteCreateCoordinator) { c in
        ZStack {
          Rectangle().foregroundColor(.black).edgesIgnoringSafeArea(.all)
          NoteCreateCoordinatorView(coordinator: c)
        }
      }
  }
}

struct NoteGroupDetailsCoordinatorView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let coordinator = appAssembler.resolve(
    NoteGroupDetailsCoordinator.self,
    argument: nil as Group?
  )!
  static var previews: some View {
    NoteGroupDetailsCoordinatorView(coordinator: coordinator)
  }
}
