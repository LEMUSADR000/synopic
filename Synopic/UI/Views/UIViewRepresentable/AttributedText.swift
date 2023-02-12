//
//  AttributedTextView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/11/23.
//

import SwiftUI
import UIKit

protocol StringFormatter { func format(string: String) -> NSAttributedString? }

struct AttributedText: UIViewRepresentable {
  typealias UIViewType = UITextView
  @State private var attributedText: NSAttributedString?
  private let text: String
  private let formatter: StringFormatter
  private var delegate: UITextViewDelegate?

  init(
    _ text: String,
    _ formatter: StringFormatter,
    delegate: UITextViewDelegate? = nil
  ) {
    self.text = text
    self.formatter = formatter
    self.delegate = delegate
  }

  func makeUIView(context: Context) -> UIViewType {
    let view = ContentTextView()
    view.setContentHuggingPriority(.required, for: .vertical)
    view.setContentHuggingPriority(.required, for: .horizontal)
    view.contentInset = .zero
    view.textContainer.lineFragmentPadding = 0
    view.delegate = delegate
    view.backgroundColor = .clear
    return view
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    guard let attributedText = attributedText else {
      generateAttributedText()
      return
    }
    uiView.attributedText = attributedText
    uiView.invalidateIntrinsicContentSize()
  }

  private func generateAttributedText() {
    guard attributedText == nil else { return }
    // create attributedText on main thread since HTML formatter will crash SwiftUI
    DispatchQueue.main.async {
      self.attributedText = self.formatter.format(string: self.text)
    }
  }

  /// ContentTextView
  /// subclass of UITextView returning contentSize as intrinsicContentSize
  private class ContentTextView: UITextView {
    override var canBecomeFirstResponder: Bool { false }
    override var intrinsicContentSize: CGSize {
      frame.height > 0 ? contentSize : super.intrinsicContentSize
    }
  }
}
