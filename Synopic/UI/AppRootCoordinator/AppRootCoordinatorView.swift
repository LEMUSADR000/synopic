//
//  AppRootCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import SwiftUI

struct AppRootCoordinatorView: View {
    @ObservedObject var coordinator: AppRootCoordinatorViewModel

    init(coordinator: AppRootCoordinatorViewModel) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationView {
            CameraView(model: self.coordinator.cameraViewModel)
        }
    }
}
