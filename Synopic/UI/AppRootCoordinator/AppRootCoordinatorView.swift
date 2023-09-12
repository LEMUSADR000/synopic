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
    ObjectNavigationStack(path: self.coordinator.navigator) {
      LandingView(viewModel: self.coordinator.landingViewModel)
        .navigationTitle("Books")
        .navigationDestination(for: NoteGroupDetailsCoordinator.self) {
          NoteGroupDetailsCoordinatorView(coordinator: $0)
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
