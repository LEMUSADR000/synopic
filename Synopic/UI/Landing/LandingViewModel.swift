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
    private let ocrService: OCRService
    private weak var delegate: LandingViewModelDelegate?
    private var cancelBag: CancelBag!
    
    init(ocrService: OCRService) {
        self.ocrService = ocrService
        
        let today = Date()
        let data = [
            today: "Today",
            Calendar.current.date(byAdding: .day, value: -1, to: today)!: "Yesterday",
            Calendar.current.date(byAdding: .day, value: -7, to: today)!: "Last Week"
        ]
        
        for d in data {
            sections.append(
                ViewSection(
                    title: d.value,
                    items: [
                        NoteGroup(created: d.key, title: "Lion's King"),
                        NoteGroup(created: d.key.adding(hours: -2), title: "Enders Game"),
                        NoteGroup(created: d.key.adding(hours: -4), title: "Star Wars"),
                    ]
                )
            )
        }
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
    @Published var searchText: String = .empty
    
    @Published var results: [LandingViewResult] = []
    
    @Published var sections: [ViewSection] = []
    
    // MARK: EVENT
    let openScanSheet: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private func onOpenSheet() {
        self.openScanSheet
            .receive(on: .main)
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

                let result = LandingViewResult(from: raw)
                self.results.append(result)
            })
            .store(in: &self.cancelBag)
    }
}

struct ViewSection: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var items: [NoteGroup]
}

struct LandingViewResult: Identifiable, Hashable {
    let id = UUID()
    let background: Color
    let image: Image
    let text: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(background: Color, image: Image, text: String) {
        self.background = background
        self.image = image
        self.text = text
    }
    
    init(from result: DocumentScanResult) {
        self.background = Color(result.image.averageUIColor ?? UIColor(.gray))
        self.image = Image(uiImage: result.image)
        self.text = result.text
    }
}

struct NoteGroup: Identifiable, Hashable {
    let id = UUID()
    let created: Date
    var title: String?
    var author: String?
    var imageName: String?
}

extension NoteGroup {
    var image: Image? {
        // TODO: Cache result of this if it appears to be an expensive operation
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        if let name = imageName, let dirPath = paths.first {
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(name)
            if let image = UIImage(contentsOfFile: imageURL.path) {
                return Image(uiImage: image)
            }
        }
        
        return nil
    }
}
