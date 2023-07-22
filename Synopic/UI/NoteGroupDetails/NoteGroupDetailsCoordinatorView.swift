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
    NavigationView {
      NotesGridView(notesGridViewModel: self.coordinator.notesGridViewModel)
        .fullScreenCover(item: self.$coordinator.noteCreateCoordinator) { c in
          NavigationView {
            ZStack {
              Rectangle().foregroundColor(.black).edgesIgnoringSafeArea(.all)
              NoteCreateCoordinatorView(coordinator: c)
            }
          }
        }
    }
  }
}
struct NoteGroupDetailsCoordinatorView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let coordinator = appAssembler.resolve(
    NoteGroupDetailsCoordinator.self,
    argument: ""
  )!
  static var previews: some View {
    NoteGroupDetailsCoordinatorView(coordinator: coordinator)
  }
}
