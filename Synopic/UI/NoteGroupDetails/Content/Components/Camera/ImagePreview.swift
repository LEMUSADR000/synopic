//
//  ImagePreview.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/10/23.
//

import SwiftUI

struct ImagePreviewView: View {
  @Binding var raw: CIImage?

  var body: some View {
    GeometryReader { geometry in
      if let image = raw?.image {
        image
          .resizable()
          .scaledToFill()
          .frame(width: geometry.size.width, height: geometry.size.height)
      }
    }
  }
}

#Preview {
  ImagePreviewView(raw: .constant(nil))
}
