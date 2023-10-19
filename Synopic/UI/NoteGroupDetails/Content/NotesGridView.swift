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

  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }

  var body: some View {
    VStack {
      HStack {
        Spacer().frame(width: 10)
        VStack {
          TextField(
            self.notesGridViewModel.model.title,
            text: self.$notesGridViewModel.model.title,
            prompt: Text("Title")
          )
          .font(.headline)
          Divider()
          TextField(
            self.notesGridViewModel.model.author,
            text: self.$notesGridViewModel.model.author,
            prompt: Text("Author")
          )
          .font(.subheadline)
          Divider()
        }
      }
      .padding(.vertical, 20)

      Spacer().frame(height: 16)
      if self.notesGridViewModel.model.notes.isEmpty {
        Spacer()
        Text("Tap scan button and begin studying!")
          .font(.title.monospaced())
          .foregroundColor(.black.opacity(0.5))
          .multilineTextAlignment(.center)
          .padding(.bottom, 50)
          .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
      } else {
        PageViewWrapper(
          selection: self.$notesGridViewModel.selected,
          currentIndicator: self.notesGridViewModel.theme
        ) {
          ForEach(Array(self.notesGridViewModel.model.notes.enumerated()), id: \.0) { i, note in
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
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
        .onTapGesture {
          self.hideKeyboard()
        }
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
      )
      .frame(height: 45)
      .foregroundColor(.black.opacity(0.6))
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
