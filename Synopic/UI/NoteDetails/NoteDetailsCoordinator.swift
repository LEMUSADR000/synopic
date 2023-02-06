//
//  NoteDetailsCoordinator.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Foundation
import Combine
import Swinject

protocol NoteDetailsCoordinatorDelegate: AnyObject {
    func noteDetailsCoordinatorDidTapCreateNote(_ source: NoteDetailsCoordinator)
}

public class NoteDetailsCoordinator: ViewModel {
    private weak var delegate: NoteDetailsCoordinatorDelegate?
    
    private var cancelBag: CancelBag!
    
    private let resolver: Resolver
    
    @Published var scanDocumentsCoordinator: ScanDocumentsCoordinator?
    
    @Published private(set) var notesGridViewModel: NotesGridViewModel!
  
    init(resolver: Resolver) {
        self.resolver = resolver
        
        self.notesGridViewModel = self.resolver.resolve(NotesGridViewModel.self)!.setup(delegate: self)
    }
    
    func setup(delegate: NoteDetailsCoordinatorDelegate) -> Self {
        self.delegate = delegate
        bind()
        return self
    }
    
    private func bind() {
        self.cancelBag = CancelBag()
    }
}

// MARK: NotesGridViewModelDelegate

extension NoteDetailsCoordinator: NotesGridViewModelDelegate {
    func notesGridViewModelDidTapViewNote(id: String, _ source: NotesGridViewModel) {
        // TODO: Navigate to 
    }
    
    func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel) {
        self.scanDocumentsCoordinator = self.resolver.resolve(ScanDocumentsCoordinator.self)!
    }
}

// MARK: ScanDocumentsViewModelDelegate

extension ScanDocumentsCoordinator: ScanDocumentsViewModelDelegate {
    func scanDocumentsViewModelDidCancel(_ source: ScanDocumentsViewModel) {
    }
    
    func scanDocumentsViewModelDidSave(_ source: ScanDocumentsViewModel) {
    }
    
    func scanDocumentsViewModelDidGenerateResult(result: String, _ source: ScanDocumentsViewModel) {
        
    }
    
    func scanDocumentsViewModelFailedToGenerateResult(_ source: ScanDocumentsViewModel) {
        
    }
}

