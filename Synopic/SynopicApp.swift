//
//  SynopicApp.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/15/22.
//

import SwiftUI

private let appAssembler: AppAssembler = AppAssembler()

@main
struct SynopicApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootCoordinatorView(coordinator: appAssembler.resolve(AppRootCoordinator.self)!)
        }
    }
}
