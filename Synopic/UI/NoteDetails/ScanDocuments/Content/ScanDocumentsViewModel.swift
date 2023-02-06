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
    func scanDocumentsViewModelDidCancel(_ source: ScanDocumentsViewModel)
    func scanDocumentsViewModelDidSave(_ source: ScanDocumentsViewModel)
    func scanDocumentsViewModelDidGenerateResult(result: String, _ source: ScanDocumentsViewModel)
    func scanDocumentsViewModelFailedToGenerateResult(_ source: ScanDocumentsViewModel)
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
        self.onSaveScans()
    }
    
    // MARK: STATE
    
    
    // MARK: EVENT
    let saveScans: PassthroughSubject<VNDocumentCameraScan, Never> = PassthroughSubject()
    let exit: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private func onSaveScans() {
        self.saveScans
            .receive(on: .main)
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.delegate?.scanDocumentsViewModelDidSave(self)
                
                do {
                    // TODO: Figure out if this task is heavy enough to need running on dispatchqueue
                    let output = try self.ocrService.processDocumentScan($0)
                    self.delegate?.scanDocumentsViewModelDidGenerateResult(result: output, self)
                } catch {
                    self.delegate?.scanDocumentsViewModelFailedToGenerateResult(self)
                }
            })
            .store(in: &self.cancelBag)
    }
    
    private func onExit() {
        self.exit
            .receive(on: .main)
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.delegate?.scanDocumentsViewModelDidCancel(self)
            })
            .store(in: &self.cancelBag)
    }
}
