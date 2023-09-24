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
  @State var isLoading: Bool
  
  let buttonHeight: CGFloat = 60

  init(viewModel: NoteCreateViewModel) {
    UITextView.appearance().backgroundColor = .black
    self.viewModel = viewModel
    self.isLoading = viewModel.isProcessing
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
      Button(action: self.viewModel.processText) {
        procesButton()
          .frame(maxWidth: .infinity, minHeight: 55)
          .background(RoundedRectangle(cornerRadius: 15))
      }
      .disabled(self.viewModel.isProcessing)
      .padding(.horizontal, 50)
      .frame(minWidth: 100, maxWidth: .infinity)
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .background(Color(UIColor.secondarySystemBackground))
    .onReceive(self.viewModel.$isProcessing) { processing in
      self.isLoading = processing
    }
  }
  
  @ViewBuilder private func procesButton() -> some View {
    if self.isLoading {
      ProgressView()
    } else {
      Image(systemName: "checkmark")
        .foregroundColor(Color(.white))
    }
  }
}

struct ProcessScansView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(NoteCreateViewModel.self)!
  static var previews: some View { ProcessScansView(viewModel: viewModel) }
}
