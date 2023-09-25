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
  
  let buttonHeight: CGFloat = 60

  init(viewModel: NoteCreateViewModel) {
    UITextView.appearance().backgroundColor = .black
    self.viewModel = viewModel
  }

  var body: some View {
    VStack {
      TextEditor(text: self.$viewModel.content)
        .cornerRadius(10)
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
      HStack {
        SummaryTypeToggle(
          model: self.$viewModel.processType,
          type: .singleSentence,
          action: {
            self.viewModel.toggleProcessMode.send(.singleSentence)
          }
        )
        Spacer().frame(width: 30)
        SummaryTypeToggle(
          model: self.$viewModel.processType,
          type: .threePoints,
          action: {
            self.viewModel.toggleProcessMode.send(.threePoints)
          }
        )
      }
      .padding(.horizontal, 50)
      .frame(minWidth: 100, maxWidth: .infinity)
      Spacer().frame(height: 20)
      LoadingButton(
        isLoading: self.$viewModel.isProcessing,
        onTap: { self.viewModel.processText.send() }
      )
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .background(Color(UIColor.secondarySystemBackground))
  }
}

struct ProcessScansView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(NoteCreateViewModel.self)!
  static var previews: some View { ProcessScansView(viewModel: viewModel) }
}
