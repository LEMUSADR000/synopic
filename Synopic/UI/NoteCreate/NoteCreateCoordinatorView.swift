//
//  NoteCreateSwiftUI.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//
import SwiftUI

struct NoteCreateCoordinatorView: View {
  @StateObject var coordinator: NoteCreateCoordinator

  var body: some View {
    NavigationView {
      ScanDocumentsView(
        noteCreateViewModel: self.coordinator.noteCreateViewModel
      )
      .edgesIgnoringSafeArea(.top)
      .edgesIgnoringSafeArea(.bottom)
      .navigation(isActive: self.$coordinator.toggleNavigation) {
        let _ = UITextView.appearance().backgroundColor = .black
        ProcessScansView(viewModel: self.coordinator.noteCreateViewModel)
      }
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

#Preview {
  NoteCreateCoordinatorView(coordinator: AppAssembler().resolve(NoteCreateCoordinator.self)!)
}
