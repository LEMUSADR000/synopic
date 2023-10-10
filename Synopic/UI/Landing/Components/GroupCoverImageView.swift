//
//  GroupCoverImageView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct GroupCoverImageView: View {
  @Binding var image: String?

  var body: some View {
    ZStack {
      Circle().foregroundColor(Color(UIColor.secondarySystemBackground))
        .frame(width: 70, height: 70, alignment: .center).cornerRadius(10)
        .shadow(color: Color(.systemGray4), radius: 2, x: 0, y: 0)
      if let path = image, let value = Image.fromFile(from: path) {
        value.resizable().aspectRatio(contentMode: .fill)
          .frame(width: 70, height: 110)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      } else {
        ZStack {
          Image(systemName: "photo")
            .resizable()
            .frame(width: 20.0, height: 20.0, alignment: .center)
            .foregroundColor(Color(UIColor.systemGray))
          Image(systemName: "circle.slash")
            .resizable()
            .frame(width: 50.0, height: 50.0, alignment: .center)
            .foregroundColor(Color(UIColor.systemGray).opacity(0.5))
        }
      }
    }
  }
}

#Preview {
  GroupCoverImageView(image: .constant(nil))
}
