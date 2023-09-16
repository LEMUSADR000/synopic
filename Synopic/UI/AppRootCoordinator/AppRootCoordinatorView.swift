//
//  AppRootCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import SwiftUI

struct AppRootCoordinatorView: View {
  @ObservedObject var coordinator: AppRootCoordinator

  init(coordinator: AppRootCoordinator) { self.coordinator = coordinator }

  var body: some View {
    NavigationView {
      LandingView(viewModel: self.coordinator.landingViewModel)
        .navigationTitle("Note Groups")
        .navigation(item: self.$coordinator.noteGroupDetailsCoordinator) { c in
          NoteGroupDetailsCoordinatorView(coordinator: c)
        }
    }.task {
      self.coordinator.landingViewModel.loadGroups()
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
