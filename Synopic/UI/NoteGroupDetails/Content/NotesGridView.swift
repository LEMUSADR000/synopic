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
      HStack {
        Button(action: self.notesGridViewModel.takePicture) {
          ImageSelection(image: self.$notesGridViewModel.model.imagePath)
            .frame(width: 70, height: 70)
        }
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
      PageViewWrapper(selection: self.$notesGridViewModel.selected) {
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

struct ImageSelection: View {
  @Binding var image: URL?

  var body: some View {
    if let url = image {
      GroupCoverImageView(image: .constant(url))
    } else {
      ZStack(alignment: .bottomTrailing) {
        Rectangle().foregroundColor(Color(UIColor.gray))
          .aspectRatio(contentMode: .fill)
          .cornerRadius(10)
        Image(systemName: "photo")
          .resizable()
          .frame(width: 40.0, height: 30.0, alignment: .center)
          .foregroundColor(Color(UIColor.systemBackground))
          .padding(.vertical, 20)
          .padding(.horizontal, 15)
        Circle()
          .frame(width: 14.0, height: 14.0, alignment: .center)
          .foregroundColor(Color(UIColor.gray))
          .padding(.bottom, 15)
          .padding(.trailing, 7.5)
        Image(systemName: "plus.circle.fill")
          .resizable()
          .frame(width: 15.0, height: 15.0, alignment: .center)
          .foregroundColor(Color(UIColor.systemBackground))
          .padding(.bottom, 15)
          .padding(.trailing, 7.5)
      }
    }
  }
}

struct NotesGridView_Previews: PreviewProvider {
  static var previews: some View {
    NotesGridView(
      notesGridViewModel: NotesGridViewModel.notesGridViewModelPreview
    )
  }
}
