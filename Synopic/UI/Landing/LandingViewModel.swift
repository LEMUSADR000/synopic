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
    func landingViewModelDidTapCreateGroup(_ source: LandingViewModel)
}

public class LandingViewModel: ViewModel {
    private let ocrService: OCRService
    private weak var delegate: LandingViewModelDelegate?
    private var cancelBag: CancelBag!
    
    init(ocrService: OCRService) {
        self.ocrService = ocrService
        
        let today = Date()
        let data = [
            today,
            Calendar.current.date(byAdding: .day, value: -1, to: today)!,
            Calendar.current.date(byAdding: .day, value: -7, to: today)!,
        ]
        
        self.sections = [
            ViewSection(
                title: "Today",
                items: [
                    NoteGroup(created: data[0], title: "Lion's King", author: "Author 1"),
                    NoteGroup(created: data[0].adding(hours: -2), title: "Enders Game", author: "Author 2"),
                    NoteGroup(created: data[0].adding(hours: -4), title: "Star Wars", author: "Author 3"),
                ]
            ),
            ViewSection(
                title: "Yesterday",
                items: [
                    NoteGroup(created: data[1], title: "Lion's King", author: "Author 1"),
                    NoteGroup(created: data[1].adding(hours: -2), title: "Enders Game", author: "Author 2"),
                ]
            ),
            ViewSection(
                title: "Last Week",
                items: [
                    NoteGroup(created: data[2], title: "Lion's King", author: "Author 1"),
                ]
            )
        ]
    }
    
    func setup(delegate: LandingViewModelDelegate) -> Self {
        self.delegate = delegate
        bind()
        return self
    }
    
    private func bind() {
        self.cancelBag = CancelBag()
        self.onCreateNote()
    }
    
    // MARK: STATE
    @Published var searchText: String = .empty
    @Published var sections: [ViewSection] = []
    
    // MARK: EVENT
    let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private func onCreateNote() {
        self.createNote
            .receive(on: .main)
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.delegate?.landingViewModelDidTapCreateGroup(self)
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
