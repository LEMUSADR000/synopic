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
    ZStack(alignment: .bottom) {
      TabView {
        NavigationView {
          LandingView(viewModel: self.coordinator.landingViewModel)
            .navigation(item: self.$coordinator.noteDetailsCoordinator) { c in
              NoteGroupDetailsCoordinatorView(coordinator: c)
            }
            .navigationTitle("Note Groups")
        }
      }
      TabBarContent(viewModel: self.coordinator.landingViewModel)
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
