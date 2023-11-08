//
//  NoteGroupDetailsCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//
import SwiftUI

struct NoteGroupDetailsCoordinatorView: View {
  @StateObject var coordinator: NoteGroupDetailsCoordinator
  @State private var isConfirmingDelete: Bool = false

  var body: some View {
    NavigationView {
      NotesGridView(notesGridViewModel: self.coordinator.notesGridViewModel)
        .fullScreenCover(item: self.$coordinator.noteCreateCoordinator) { c in
          ZStack {
            Rectangle().foregroundColor(.black).edgesIgnoringSafeArea(.all)
            NoteCreateCoordinatorView(coordinator: c)
          }
        }
        .sheet(item: self.$coordinator.cameraViewModel) { c in
          CameraView(model: c)
        }
    }
    .navigationViewStyle(StackNavigationViewStyle())
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle("")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        if self.coordinator.notesGridViewModel.canDelete {
          Button("Delete", role: .destructive) {
            self.isConfirmingDelete = true
          }
          .foregroundColor(.red)
          .confirmationDialog(
            "Are you sure?",
            isPresented: self.$isConfirmingDelete
          ) {
            Button("Delete group", role: .destructive) {
              self.coordinator.notesGridViewModel.deleteGroup.send()
            }
          }
        } else {
          Spacer().frame(height: 0)
        }
      }
    }
  }
}

struct NoteGroupDetailsCoordinatorView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let coordinator = appAssembler.resolve(
    NoteGroupDetailsCoordinator.self,
    argument: Group(title: "Title", author: "Author", childCount: 12)
  )!
  static var previews: some View {
    NoteGroupDetailsCoordinatorView(coordinator: coordinator)
  }
}
