//
//  NotesGridViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import Foundation
import Combine

protocol NotesGridViewModelDelegate: AnyObject {
    func notesGridViewModelDidTapCreateNote(_ source: NotesGridViewModel)
    func notesGridViewModelDidTapViewNote(id: String, _ source: NotesGridViewModel)
}

public class NotesGridViewModel: ViewModel {
    private weak var delegate: NotesGridViewModelDelegate?
    private var cancelBag: CancelBag!
    
    func setup(delegate: NotesGridViewModelDelegate) -> Self {
        self.delegate = delegate
        bind()
        return self
    }
    
    private func bind() {
        self.cancelBag = CancelBag()
        self.onCreateNote()
        self.onViewNote()
    }
    
    // MARK: STATE
    
    // MARK: EVENT
    let createNote: PassthroughSubject<Void, Never> = PassthroughSubject()
    let viewNote: PassthroughSubject<String, Never> = PassthroughSubject()
    
    private func onCreateNote() {
        self.createNote
            .receive(on: .main)
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.delegate?.notesGridViewModelDidTapCreateNote(self)
            })
            .store(in: &self.cancelBag)
    }
    
    private func onViewNote() {
        self.viewNote
            .receive(on: .main)
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.delegate?.notesGridViewModelDidTapViewNote(id: $0, self)
            })
            .store(in: &self.cancelBag)
    }
}
