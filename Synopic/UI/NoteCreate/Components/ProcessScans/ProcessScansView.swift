//
//  ProcessScansView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/6/23.
//

import SwiftUI
import Swinject

struct ProcessScansView: View {
  @StateObject var viewModel: NoteCreateViewModel

  let buttonHeight: CGFloat = 60

  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
          type: .sentence,
          action: {
            self.viewModel.toggleProcessMode.send(.sentence)
          }
        )
        Spacer().frame(width: 30)
        SummaryTypeToggle(
          model: self.$viewModel.processType,
          type: .bullets,
          action: {
            self.viewModel.toggleProcessMode.send(.bullets)
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
    .padding(.bottom, 20)
    .background(Color(UIColor.secondarySystemBackground))
    .onTapGesture {
      self.hideKeyboard()
    }
  }
}

#Preview {
  let model = AppAssembler().resolve(NoteCreateViewModel.self)!
  return ProcessScansView(viewModel: model)
}
