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
      PageViewWrapper(selection: self.$notesGridViewModel.selected) {
        ForEach(Array(self.notesGridViewModel.notes.enumerated()), id: \.0) { i, note in
          NoteCardView {
            Text(note.summary)
              .fontWeight(.light)
              .font(.system(size: 36))
              .multilineTextAlignment(.leading)
              .minimumScaleFactor(0.1)
              .padding()
          }
          .tag(i)
          .padding()
        }.padding(.bottom, 50)
      }
      Spacer()
    }
    .toolbar {
      Button(
        action: { self.notesGridViewModel.createNote.send() },
        label: {
          ZStack {
            Image(systemName: "viewfinder")
              .resizable()
              .aspectRatio(contentMode: .fill)
            Image(systemName: "book")
          }
        }
      ).frame(height: 45)
    }
    .padding(.horizontal, 24).navigationBarTitle("", displayMode: .inline)
    .onDisappear {
      self.notesGridViewModel.saveGroup()
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
