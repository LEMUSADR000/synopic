//
//  LandingViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import Foundation
import Combine
import SwiftUI

protocol LandingViewModelDelegate: AnyObject {
    func landingViewModelDidTapOpenSheet(_ source: LandingViewModel)
}

public class LandingViewModel: ViewModel {
    private let ocrService: OCRServiceProtocol
    private weak var delegate: LandingViewModelDelegate?
    private var cancelBag: CancelBag!
    
    init(ocrService: OCRServiceProtocol) {
        self.ocrService = ocrService
    }
    
    func setup(delegate: LandingViewModelDelegate) -> Self {
        self.delegate = delegate
        bind()
        return self
    }
    
    private func bind() {
        self.cancelBag = CancelBag()
        self.onOpenSheet()
        self.onScanResult()
    }
    
    // MARK: STATE
    @Published private(set) var results: [LandingViewResult] = []
    
    // MARK: EVENT
    let openScanSheet: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private func onOpenSheet() {
        self.openScanSheet
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.delegate?.landingViewModelDidTapOpenSheet(self)
            })
            .store(in: &self.cancelBag)
    }
    
    private func onScanResult() {
        self.ocrService.documentScanResults
            .receive(on: .main)
            .sink(receiveValue: { [weak self] in
                guard let self = self, let raw = $0 else { return }
                
                let result = LandingViewResult.init(from: raw)
                self.results.append(result)
            })
            .store(in: &self.cancelBag)
    }
}

struct LandingViewResult {
    let background: Color
    let image: Image
    let text: String
}

extension LandingViewResult {
    init(from result: DocumentScanResult) {
        background = Color(result.image.averageUIColor ?? UIColor(.gray))
        image = Image(uiImage: result.image)
        text = result.text
    }
}
