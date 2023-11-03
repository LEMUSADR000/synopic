//
//  CardView.swift
//  Synopic
//
//  Created by adrian.lemus on 11/2/23.
//

import SwiftUI

struct CardView<Content>: View where Content: View {
  let background: Color
  private var content: () -> Content

  @inlinable init(background: Color, @ViewBuilder content: @escaping () -> Content) {
    self.background = background
    self.content = content
  }

  var body: some View {
    ZStack(alignment: .topTrailing) {
      content()
        .background(background)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
      Button(action: {
        // Handle the exit button action here
        print("Exit button tapped")
      }) {
        Image(systemName: "xmark.circle.fill")
          .foregroundColor(.primary)
          .padding()
      }
      .padding()
    }
  }
}

#Preview {
  CardView(background: Color.generateRandomPastelColor()) {
    Text("test")
      .frame(width: 200, height: 200)
  }
}
