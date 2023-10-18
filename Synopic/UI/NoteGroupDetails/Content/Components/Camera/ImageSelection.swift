//
//  ImageSelection.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/18/23.
//

import SwiftUI

struct ImageSelection: View {
  @Binding var image: URL?

  var body: some View {
    if let url = image {
      GroupCoverImageView(image: .constant(url))
    } else {
      ZStack(alignment: .bottomTrailing) {
        Rectangle().foregroundColor(Color(UIColor.gray))
          .aspectRatio(contentMode: .fill)
          .cornerRadius(10)
        Image(systemName: "photo")
          .resizable()
          .frame(width: 40.0, height: 30.0, alignment: .center)
          .foregroundColor(Color(UIColor.systemBackground))
          .padding(.vertical, 20)
          .padding(.horizontal, 15)
        Circle()
          .frame(width: 14.0, height: 14.0, alignment: .center)
          .foregroundColor(Color(UIColor.gray))
          .padding(.bottom, 15)
          .padding(.trailing, 7.5)
        Image(systemName: "plus.circle.fill")
          .resizable()
          .frame(width: 15.0, height: 15.0, alignment: .center)
          .foregroundColor(Color(UIColor.systemBackground))
          .padding(.bottom, 15)
          .padding(.trailing, 7.5)
      }
    }
  }
}

#Preview {
  ImageSelection(
    image: .constant(URL(string: ""))
  )
}
