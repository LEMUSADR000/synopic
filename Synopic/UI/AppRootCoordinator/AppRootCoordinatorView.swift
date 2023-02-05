//
//  AppRootCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import SwiftUI

struct AppRootCoordinatorView: View {
    @ObservedObject var coordinator: AppRootCoordinator

    init(coordinator: AppRootCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationView {
            LandingView(/*viewModel: self.coordinator.landingViewModel*/)
                .navigationTitle("Books")
                .fullScreenCover(item: $coordinator.scanDocumentsCoordinator) { c in
                    NavigationView {
                        ZStack {
                            Rectangle().foregroundColor(.black).edgesIgnoringSafeArea(.all)
                            ScanDocumentsCoordinatorView(coordinator: c)
                        }
                    }
                }
        }
    }
}
