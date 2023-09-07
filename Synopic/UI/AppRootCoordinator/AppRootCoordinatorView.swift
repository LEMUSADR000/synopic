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
    NavigationStack(path: self.$coordinator.path) {
      LandingView(viewModel: self.coordinator.landingViewModel)
        .navigationTitle("Note Groups")
        .navigationDestination(for: PathBundle.self) { bundle in
          switch(bundle.path) {
          case NoteGroupDetailsCoordinatorView.path:
            NoteGroupDetailsCoordinatorView(coordinator: bundle.model as! NoteGroupDetailsCoordinator)
              .navigationBarBackButtonHidden(true)
              .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                  CustomBack(action: {_ = self.coordinator.path.popLast()})
                }
              }
          default:
            Text("Unhandled path \(bundle.path)")
          }
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
