//
//  NotesGridView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI
import Swinject

struct NotesGridView: View {
  @ObservedObject var notesGridViewModel: NotesGridViewModel

  // TODO: Make column stateful so we can toggle between grids, lists, etc. as a feature
  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    VStack {
      VStack {
        TextField(notesGridViewModel.title, text: $notesGridViewModel.title, prompt: Text("Title"))
          .font(.headline)
        Divider()
        TextField(
          notesGridViewModel.author, text: $notesGridViewModel.author, prompt: Text("Author")
        )
        .font(.subheadline)
        Divider()
      }
      .padding(.horizontal, 20)
      .padding(.vertical, 20)

      Spacer().frame(height: 16)
      ScrollView {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(notesGridViewModel.notes) { note in
            Button(
              action: { self.notesGridViewModel.viewNote.send(note.id) },
              label: {
                NoteCardView {
                  Text(note.content)
                }
              })
          }
          Button(action: self.notesGridViewModel.createNote) {
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

  func onNoteSend(id: String) {
    self.notesGridViewModel.viewNote.send(id)
  }
}

struct NotesGridView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(NotesGridViewModel.self, argument: "id")!

  static var previews: some View {
    NotesGridView(notesGridViewModel: viewModel)
  }
}
