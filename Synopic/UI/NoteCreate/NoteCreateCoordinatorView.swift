//
//  NoteCreateSwiftUI.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//
import SwiftUI

struct NoteCreateCoordinatorView: View {
  @ObservedObject var coordinator: NoteCreateCoordinator
  init(coordinator: NoteCreateCoordinator) { self.coordinator = coordinator }
  var body: some View {
    ScanDocumentsView(
      noteCreateViewModel: self.coordinator.noteCreateViewModel
    )
    // TODO: Plug scans modal navigation back in!
    //    .navigation(isActive: self.$coordinator.toggleNavigation) {
    //      ProcessScansView(viewModel: self.coordinator.noteCreateViewModel)
    //    }
  }
}
struct NoteCreateCoordinatorView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let coordinator = appAssembler.resolve(NoteCreateCoordinator.self)!
  static var previews: some View {
    NoteCreateCoordinatorView(coordinator: coordinator)
  }
}
