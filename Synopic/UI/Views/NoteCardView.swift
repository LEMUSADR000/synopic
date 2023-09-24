//
//  ExpandingCardView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/29/23.
//

import SwiftUI

struct NoteCardView<Content>: View where Content: View {
  var background: Color
  private var content: () -> Content

  @inlinable init(@ViewBuilder content: @escaping () -> Content) {
    self.init(
      background: Color(UIColor.secondarySystemBackground),
      content: content
    )
  }

  init(background: Color, @ViewBuilder content: @escaping () -> Content) {
    self.background = background
    self.content = content
  }

  var body: some View {
    RoundedRectangle(cornerRadius: 10, style: .continuous)
      .foregroundColor(background).aspectRatio(0.6, contentMode: .fill)
      .overlay(content())
  }
}

struct NoteCardView_Preview: PreviewProvider {
  static var previews: some View {
    NoteCardView(background: .gray.opacity(0.2)) {
      Spacer().frame(minHeight: 200)
    }
  }
}
