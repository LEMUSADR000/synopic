//
//  CardView.swift
//  Synopic
//
//  Created by adrian.lemus on 11/2/23.
//

import SwiftUI

typealias OnTap = () -> Void

struct CardView<Content>: View where Content: View {
  let background: Color
  private var content: () -> Content
  private let onTap: OnTap?

  @inlinable init(
    background: Color,
    onTap: OnTap?,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.background = background
    self.content = content
    self.onTap = onTap
  }

  var body: some View {
    ZStack(alignment: .topTrailing) {
      content()
        .background(background)
        .cornerRadius(10)
        .shadow(radius: 5)
      Button(action: onTap ?? {}) {
        Image(systemName: "xmark.circle.fill")
          .foregroundColor(.primary.opacity(0.5))
      }
      .padding(.trailing, 10)
      .padding(.top, 10)
    }
  }
}

#Preview {
  CardView(
    background: Color.generateRandomPastelColor(),
    onTap: {
      print("tapped")
    }
  ) {
    Text("test")
      .frame(width: 200, height: 200)
  }
}
