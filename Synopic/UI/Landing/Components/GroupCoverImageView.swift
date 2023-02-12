//
//  GroupCoverImageView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct GroupCoverImageView: View {
  let image: Image?

  var body: some View {
    ZStack {
      Rectangle().foregroundColor(Color(UIColor.secondarySystemBackground))
        .frame(width: 70, height: 100, alignment: .center).cornerRadius(10)
        .shadow(color: Color(.systemGray4), radius: 5, x: 0, y: 0)
      if let value = image {
        value.resizable().aspectRatio(contentMode: .fill)
          .frame(width: 70, height: 110)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      else {
        Image(systemName: "camera.circle.fill")
          .foregroundColor(Color(UIColor.systemGray))
      }
    }
  }
}

struct GroupCoverImageView_Previews: PreviewProvider {
  static let image = Image("lion_king_cover")
  static var previews: some View { GroupCoverImageView(image: nil) }
}
