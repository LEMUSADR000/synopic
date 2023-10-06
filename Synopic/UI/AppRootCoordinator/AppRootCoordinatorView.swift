//
//  AppRootCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import SwiftUI

struct AppRootCoordinatorView: View {
  @StateObject var coordinator: AppRootCoordinator

  var body: some View {
    NavigationView {
      LandingView(viewModel: self.coordinator.landingViewModel)
        .navigationTitle("Note Groups")
        .navigation(item: self.$coordinator.noteGroupDetailsCoordinator) { c in
          NoteGroupDetailsCoordinatorView(coordinator: c)
        }
    }
  }
}

struct AppRootCoordinatorView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let coordinator = appAssembler.resolve(AppRootCoordinator.self)!

  static var previews: some View {
    AppRootCoordinatorView(coordinator: coordinator)
  }
}
