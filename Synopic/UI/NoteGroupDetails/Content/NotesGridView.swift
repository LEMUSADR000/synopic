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

  @State var title: String = .empty
  @State var author: String = .empty

  // TODO: Make column stateful so we can toggle between grids, lists, etc. as a feature
  let columns = [
    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
  ]

  var body: some View {
    // TODO: Call view model.store on navigate back!
    VStack {
      VStack {
        TextField(
          self.title,
          text: self.$title,
          prompt: Text("Title")
        )
        .font(.headline)
        Divider()
        TextField(
          self.author,
          text: self.$author,
          prompt: Text("Author")
        )
        .font(.subheadline)
        Divider()
      }
      .padding(.horizontal, 20).padding(.vertical, 20)

      Spacer().frame(height: 16)
      ScrollView {
        LazyVGrid(columns: columns, spacing: 10) {
          ForEach(notesGridViewModel.notes) { note in
            Button(
              action: { self.notesGridViewModel.viewNote.send(note.id) },
              label: { NoteCardView { Text(note.summary) } }
            )
          }
          Button(
            action: { self.notesGridViewModel.createNote.send() },
            label: {
              NoteCardView { Image(systemName: "plus") }
            }
          )
        }
      }
      Spacer()
    }
    .padding(.horizontal, 24).navigationBarTitle("", displayMode: .inline)
    .onReceive(self.notesGridViewModel.title) { title in
      self.title = title
    }
    .onReceive(self.notesGridViewModel.author) { author in
      self.author = author
    }
  }

  func onNoteSend(id: String) { self.notesGridViewModel.viewNote.send(id) }
}

struct NotesGridView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(
    NotesGridViewModel.self,
    argument: "id"
  )!

  static var previews: some View {
    NotesGridView(notesGridViewModel: viewModel)
  }
}
