//
//  LoadingButton.swift
//  Synopic
//
//  Created by Adrian Lemus on 9/25/23.
//

import Foundation
import SwiftUI

struct LoadingButton: View {
  @Binding var isLoading: Bool
  let onTap: () -> Void
  
  var body: some View {
    Button(action: onTap) {
      procesButton()
        .frame(maxWidth: .infinity, minHeight: 55)
        .background(RoundedRectangle(cornerRadius: 15))
    }
    .foregroundColor(.accentColor)
    .opacity(self.isLoading ? 0.25 : 1.0)
    .disabled(self.isLoading)
    .padding(.horizontal, 50)
    .frame(minWidth: 100, maxWidth: .infinity)
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
