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
    
    init(_ scanDocumentsCoordinator: ScanDocumentsCoordinator) {
        self.scanDocumentsCoordinator = scanDocumentsCoordinator
    }
    
    func makeCoordinator() -> ScanDocumentsCoordinator {
        scanDocumentsCoordinator
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
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
        ScanDocumentsCoordinatorView(appAssembler.resolve(ScanDocumentsCoordinator.self)!)
    }
}
