//
//  ColorSchemeAwareColorInverter.swift
//  Synopic
//
//  Created by adrian.lemus on 10/25/23.
//

import SwiftUI

struct ColorSchemeAwareColorInverter<Content>: View where Content: View {
  @ViewBuilder let collection: () -> Content
  @Environment(\.colorScheme) var colorScheme

  @inlinable init(
    @ViewBuilder _ collection: @escaping () -> Content
  ) {
    self.collection = collection
  }

  var body: some View {
    if colorScheme == .dark {
      collection().colorInvert()
    } else {
      collection()
    }
  }
}

#Preview {
  ColorSchemeAwareColorInverter {
    Text("Hello!")
  }
}
