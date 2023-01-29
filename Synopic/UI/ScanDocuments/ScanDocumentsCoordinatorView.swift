//
//  ScanDocumentsView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/25/23.
//

import SwiftUI
import VisionKit
import Vision

struct ScanDocumentsCoordinatorView: UIViewControllerRepresentable {
    private var scanDocumentsCoordinator: ScanDocumentsCoordinator
    
    init(coordinator: ScanDocumentsCoordinator) {
        self.scanDocumentsCoordinator = coordinator
    }
    
    func makeCoordinator() -> ScanDocumentsCoordinator {
        scanDocumentsCoordinator
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        // TODO: Figure out how to delay creatin of VNDocumentCameraViewController in order to check if scanning is supported on running device
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }
}

struct ScanDocumentsView_Previews: PreviewProvider {
    static let appAssembler = AppAssembler()

    static var previews: some View {
        ScanDocumentsCoordinatorView(coordinator: appAssembler.resolve(ScanDocumentsCoordinator.self)!)
    }
}
