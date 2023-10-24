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
  @State private var isConfirmingDelete: Bool = false

  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      VStack {
        TextField(
          self.notesGridViewModel.model.title,
          text: self.$notesGridViewModel.model.title,
          prompt: Text("Title")
        )
        .font(.headline)
        .frame(height: 45)
        Divider()
        TextField(
          self.notesGridViewModel.model.author,
          text: self.$notesGridViewModel.model.author,
          prompt: Text("Author")
        )
        .font(.subheadline)
        .frame(height: 45)
        Divider()
      }
      .padding(.horizontal, 24)

      Spacer().frame(height: 20)

      VStack(alignment: .center) {
        if self.notesGridViewModel.model.notes.isEmpty {
          Spacer()
          HStack(alignment: .center) {
            Text("Tap scan button and begin studying!")
              .font(.title.monospaced())
              .foregroundColor(.primary.opacity(0.5))
              .multilineTextAlignment(.center)
              .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
          }
          Spacer()
        } else {
          PageViewWrapper(
            selection: self.$notesGridViewModel.selected,
            currentIndicator: UIColor(self.notesGridViewModel.theme)
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
            }.padding(.bottom, 25)
          }
        }
      }
      .padding(.horizontal, 24)
      .onTapGesture {
        self.hideKeyboard()
      }
      Spacer()
    }
    .toolbar {
      ToolbarItem(placement: .bottomBar) {
        Button(
          action: { self.notesGridViewModel.createNote.send() },
          label: {
            ZStack {
              Image(systemName: "viewfinder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 45)
              Image(systemName: "book")
            }
          }
        )
        .foregroundColor(.black.opacity(0.6))
      }
      ToolbarItem(placement: .destructiveAction) {
        if self.notesGridViewModel.canDelete {
          Button("Delete", role: .destructive) {
            self.isConfirmingDelete = true
          }
          .foregroundColor(.red)
          .font(.system(size: 15))
          .confirmationDialog(
            "Are you sure?",
            isPresented: self.$isConfirmingDelete
          ) {
            Button("Delete group", role: .destructive) {
              self.notesGridViewModel.deleteGroup.send()
            }
          }
        } else {
          Spacer().frame(height: 0)
        }
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
