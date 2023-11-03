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

  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }

  var body: some View {
    ZStack {
      VStack(alignment: .leading, spacing: 0) {
        VStack {
          TextField(
            self.notesGridViewModel.model.title,
            text: self.$notesGridViewModel.model.title,
            prompt: Text("Title")
          )
          .font(.headline)
          .frame(height: 25)
          .padding()
          .cornerRadius(5)
          Divider()
          TextField(
            self.notesGridViewModel.model.author,
            text: self.$notesGridViewModel.model.author,
            prompt: Text("Author")
          )
          .font(.subheadline)
          .frame(height: 25)
          .padding()
          .cornerRadius(5)
          Divider()
        }
        .padding(.horizontal, 24)

        Spacer().frame(height: 20)

        HStack {
          Spacer()
          VStack {
            if self.notesGridViewModel.model.notes.isEmpty {
              Spacer()
              HStack(alignment: .center) {
                Text("Tap to begin scanning!")
                  .font(.title.monospaced())
                  .foregroundColor(.primary.opacity(0.5))
                  .multilineTextAlignment(.center)
                  .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
              }
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
              .foregroundColor(.primary.opacity(0.6))
              Spacer()
            } else {
              PageViewWrapper(
                selection: self.$notesGridViewModel.selected,
                currentIndicator: UIColor(self.notesGridViewModel.theme)
              ) {
                ForEach(Array(self.notesGridViewModel.model.notes.enumerated()), id: \.0) { i, note in
                  CardView(background: self.notesGridViewModel.theme) {
                    VStack {
                      Spacer()
                      HStack {
                        Spacer()
                        Text(note.summary)
                          .fontWeight(.light)
                          .font(.system(size: 36))
                          .multilineTextAlignment(.leading)
                          .minimumScaleFactor(0.1)
                          .padding()
                        Spacer()
                      }
                      Spacer()
                    }
                  }
                  .tag(i)
                  .padding()
                }.padding(.bottom, 25)
              }
            }
          }
          Spacer()
        }
        .padding(.horizontal, 24)
        .onTapGesture {
          self.hideKeyboard()
        }
        Spacer().frame(height: 50)
      }

      VStack {
        Spacer()
        if self.notesGridViewModel.model.notes.count == 0 {
          Spacer().frame(height: 0)
            .transition(AnyTransition.slide.animation(.easeInOut(duration: 0.35)))
        } else {
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
          .foregroundColor(.primary.opacity(0.6))
          .frame(height: 50)
          .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
        }
      }
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .navigationBarHidden(true)
    .onDisappear {
      self.notesGridViewModel.saveGroup()
    }
  }

  func onNoteSend(id: InternalObjectId) { self.notesGridViewModel.viewNote.send(id) }
}

#Preview {
  NotesGridView(
    notesGridViewModel: NotesGridViewModel.notesGridViewModelPreview
  )
}
