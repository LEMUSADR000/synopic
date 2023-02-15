//
//  AppRootCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import SwiftUI

struct AppRootCoordinatorView: View {
  @ObservedObject var coordinator: AppRootCoordinator
  @StateObject private var router = Router()

  init(coordinator: AppRootCoordinator) { self.coordinator = coordinator }

  var body: some View {
    ZStack(alignment: .bottom) {
      TabView {
        NavigationView {
          LandingView(viewModel: self.coordinator.landingViewModel)
            .navigation(
              router: self.router,
              destination: { bundle in
                switch bundle.path {
                case "create":
                  Text("CREATE")
                default:
                  Text("whoooops")
                }
              }
            )
            .navigationTitle("Note Groups")
        }
      }
      TabBarContent(viewModel: self.coordinator.landingViewModel)
    }
    .environmentObject(router)
  }
}

struct AppRootCoordinatorView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let coordinator = appAssembler.resolve(AppRootCoordinator.self)!

  static var previews: some View {
    AppRootCoordinatorView(coordinator: coordinator)
  }
}
