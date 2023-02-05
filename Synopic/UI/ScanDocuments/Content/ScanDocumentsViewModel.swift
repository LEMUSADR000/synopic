//
//  ScanDocumentsViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/29/23.
//

import Foundation
import Combine
import VisionKit
import Vision

protocol ScanDocumentsViewModelDelegate: AnyObject {
    // Nothing yet
}

public class ScanDocumentsViewModel: ViewModel {
    private let ocrService: OCRService
    
    private var cancelBag: CancelBag!
    
    private weak var delegate: ScanDocumentsViewModelDelegate?
    
    init(ocrService: OCRService) {
        self.ocrService = ocrService
    }
    
    func setup(delegate: ScanDocumentsViewModelDelegate) -> Self {
        self.delegate = delegate
        bind()
        return self
    }

    private func bind() {
        self.cancelBag = CancelBag()
    }
    
    func addScan(_ scan: VNDocumentCameraScan) {
        self.ocrService.processDocumentScan(scan)
    }
}
