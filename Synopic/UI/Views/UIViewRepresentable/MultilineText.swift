//
//  UITextField.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/11/23.
//
import SwiftUI
import UIKit

struct MultilineText: UIViewRepresentable {
  typealias UIViewType = UITextView

  @Binding var text: String

  func makeUIView(context: Context) -> UIViewType {
    let view = ContentTextView()
    view.setContentHuggingPriority(.required, for: .vertical)
    view.setContentHuggingPriority(.required, for: .horizontal)
    view.contentInset = .zero
    view.textContainer.lineFragmentPadding = 0
    view.backgroundColor = .clear
    return view
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    uiView.invalidateIntrinsicContentSize()
    uiView.text = text
  }

  /// ContentTextView
  /// subclass of UITextView returning contentSize as intrinsicContentSize
  private class ContentTextView: UITextView {
    override var canBecomeFirstResponder: Bool { true }
    override var intrinsicContentSize: CGSize {
      frame.height > 0 ? contentSize : super.intrinsicContentSize
    }
  }
}
