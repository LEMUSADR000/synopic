//
//  ProcessScansView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/6/23.
//

import SwiftUI
import Swinject

struct ProcessScansView: View {
  @ObservedObject var viewModel: NoteCreateViewModel

  var body: some View {
    VStack {
      ScrollView {
        TextField(
          viewModel.content,
          text: $viewModel.content,
          prompt: Text("Empty")
        )
        .font(.headline)
      }
      Spacer()
      HStack {
        Button(
          action: { viewModel.toggleProcessMode.send(.singleLine) },
          label: {
            NoteCardView {

            }
          }
        )
        Spacer()
        Button(
          action: { viewModel.toggleProcessMode.send(.bulleted) },
          label: {
            NoteCardView {

            }
          }
        )
      }
    }
  }
}

struct ProcessScansView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(NoteCreateViewModel.self)!
  static var previews: some View { ProcessScansView(viewModel: viewModel) }
}
