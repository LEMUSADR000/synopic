//
//  NotesGridView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct NotesGridView: View {
    var viewModel: NotesGridViewModel
    
    @State var data: [String] = []

    // TODO: Make column stateful so we can toggle between grids, lists, etc. as a feature
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack {
            TextField("Title", text: .constant(""))
                .padding(.horizontal, 4).padding(.vertical, 5)
                .font(.headline)
            Divider()
            TextField("Author", text: .constant(""))
                .padding(.horizontal, 4).padding(.vertical, 5)
                .font(.subheadline)
            Divider()
            Spacer().frame(height: 16)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<data.count, id: \.self) { i in
                        NoteCardView {
                            Text(data[i])
                        }
                    }
                    Button(action: self.viewModel.createNote) {
                        NoteCardView {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .navigationBarTitle("", displayMode: .inline)
    }
}

struct NotesGridView_Previews: PreviewProvider {
    static let appAssembler = AppAssembler()
    static let viewModel = appAssembler.resolve(NotesGridViewModel.self)!
    
    static var previews: some View {
        NotesGridView(viewModel: viewModel)
    }
}
