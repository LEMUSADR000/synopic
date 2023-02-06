//
//  ScanDocumentsCoordinator.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import Foundation
import VisionKit
import Vision
import SwiftUI
import Swinject

class ScanDocumentsCoordinator: NSObject, VNDocumentCameraViewControllerDelegate, ViewModel {
    private let resolver: Resolver
    let scanDocumentsViewModel: ScanDocumentsViewModel!
    
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.scanDocumentsViewModel = self.resolver.resolve(ScanDocumentsViewModel.self)!
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        self.scanDocumentsViewModel.saveScans.send(scan)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        self.scanDocumentsViewModel.exit.send()
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        self.scanDocumentsViewModel.exit.send()
    }
}
