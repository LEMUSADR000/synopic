//
//  NotesGridView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import CoreData
import SwiftUI
import Swinject

struct NotesGridView: View {
  @StateObject var notesGridViewModel: NotesGridViewModel

  let horizontalPadding: CGFloat = 10

  var body: some View {
    // TODO: Call view model.store on navigate back!
    VStack {
      VStack {
        TextField(
          self.notesGridViewModel.title,
          text: self.$notesGridViewModel.title,
          prompt: Text("Title")
        )
        .font(.headline)
        Divider()
        TextField(
          self.notesGridViewModel.author,
          text: self.$notesGridViewModel.author,
          prompt: Text("Author")
        )
        .font(.subheadline)
        Divider()
      }
      .padding(.horizontal, 20).padding(.vertical, 20)

      Spacer().frame(height: 16)
      ScrollView {
        LazyVGrid(
          columns: [GridItem](
            repeating: GridItem(
              .flexible()
            ),
            count: 3
          ),
          spacing: 10
        ) {
          ForEach(0..<notesGridViewModel.notes.count, id: \.self) { i in
            NoteCardView {
              VStack(alignment: .leading) {
                Text(notesGridViewModel.notes[i].summary)
                  .fontWeight(.light)
                  .font(.system(size: 12))
                  .multilineTextAlignment(.leading)
                  .lineLimit(14)
                  .minimumScaleFactor(0.5)
                  .padding(.vertical, 5)
                  .padding(.horizontal, 2.5)
                Spacer()
              }
              .padding(5)
            }
          }
          Button(
            action: { self.notesGridViewModel.createNote.send() },
            label: {
              NoteCardView { Image(systemName: "plus").frame(idealHeight: 80) }
            }
          )
        }
      }
      Spacer()
    }
    .padding(.horizontal, 24).navigationBarTitle("", displayMode: .inline)
    .onDisappear {
      Task {
        await self.notesGridViewModel.saveGroup()
      }
    }
  }

  func onNoteSend(id: InternalObjectId) { self.notesGridViewModel.viewNote.send(id) }
}

struct NotesGridView_Previews: PreviewProvider {
  static var previews: some View {
    NotesGridView(
      notesGridViewModel: NotesGridViewModel.notesGridViewModelPreview
    )
  }
}
