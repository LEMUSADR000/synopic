//
//  PageViewWrapper.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/5/23.
//

import SwiftUI

struct PageViewWrapper<Content>: View where Content: View {
  @ViewBuilder let collection: () -> Content
  @Binding var selection: Int

  @inlinable init(
    selection: Binding<Int>, _ currentIndicator: UIColor = .systemBlue,
    @ViewBuilder _ collection: @escaping () -> Content
  ) {
    UIPageControl.appearance().currentPageIndicatorTintColor = currentIndicator
    UIPageControl.appearance().pageIndicatorTintColor = currentIndicator.withAlphaComponent(0.2)
    self.collection = collection
    self._selection = selection
  }

  var body: some View {
    TabView(selection: self.$selection, content: { collection() })
      .tabViewStyle(PageTabViewStyle())
      .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
  }
}

#Preview {
  PageViewWrapper(selection: .constant(0)) {
    Text("center")
  }
}
