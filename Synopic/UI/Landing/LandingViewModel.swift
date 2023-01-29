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
    private weak var delegate: LandingViewModelDelegate?
    private var cancelBag: CancelBag!
    
    func setup(delegate: LandingViewModelDelegate) -> Self {
        self.delegate = delegate
        bind()
        return self
    }
    
    private func bind() {
        self.cancelBag = CancelBag()
        self.onOpenSheet()
    }
    
    // MARK: STATE
    @Published var items = [String]()
    
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
}
