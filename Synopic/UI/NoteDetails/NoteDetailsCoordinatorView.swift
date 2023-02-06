//
//  NoteDetailsCoordinatorView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct NoteDetailsCoordinatorView: View {
    @ObservedObject var noteDetailsCoordinator: NoteDetailsCoordinator

    init(coordinator: NoteDetailsCoordinator) {
        self.noteDetailsCoordinator = coordinator
    }
    
    var body: some View {
        NotesGridView(viewModel: self.noteDetailsCoordinator.notesGridViewModel)
            .sheet(item: self.$noteDetailsCoordinator.scanDocumentsCoordinator) { c in
                NavigationView {
                    ZStack {
                        Rectangle().foregroundColor(.black).edgesIgnoringSafeArea(.all)
                        ScanDocumentsCoordinatorView(coordinator: c)
                    }
                }
            }
    }
}

struct NoteDetailsCoordinatorView_Previews: PreviewProvider {
    static let appAssembler = AppAssembler()
    static let coordinator = appAssembler.resolve(NoteDetailsCoordinator.self)!
    
    static var previews: some View {
        NoteDetailsCoordinatorView(coordinator: coordinator)
    }
}
