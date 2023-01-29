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

protocol ScanDocumentsCoordinatorDelegate: AnyObject {
    func scanDocumentsViewModelDidCancel(_ source: ScanDocumentsCoordinator)
    func scanDocumentsViewModelDidSave(_ source: ScanDocumentsCoordinator)
}

class ScanDocumentsCoordinator: NSObject, VNDocumentCameraViewControllerDelegate, ViewModel {
    private let resolver: Resolver
    
    private weak var delegate: ScanDocumentsCoordinatorDelegate?
    
    var scanDocumentsViewModel: ScanDocumentsViewModel!
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func setup(delegate: ScanDocumentsCoordinatorDelegate) -> Self {
      self.delegate = delegate
      
      self.scanDocumentsViewModel = self.resolver.resolve(ScanDocumentsViewModel.self)!
            .setup(delegate: self)
      
      return self
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        self.scanDocumentsViewModel.addScan(scan)
        self.delegate?.scanDocumentsViewModelDidSave(self)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        // Handle failures here
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        self.delegate?.scanDocumentsViewModelDidCancel(self)
    }
}

extension ScanDocumentsCoordinator: ScanDocumentsViewModelDelegate {
    // Nothing yet
}
