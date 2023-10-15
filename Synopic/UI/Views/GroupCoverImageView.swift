//
//  GroupCoverImageView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct GroupCoverImageView: View {
  @Binding var image: URL

  var body: some View {
    AsyncImage(url: image) { loaded in
      loaded.resizable().aspectRatio(contentMode: .fill)
        .frame(width: 70, height: 70, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .cornerRadius(3)
        .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
    } placeholder: {
      ZStack(alignment: .center) {
        Rectangle().foregroundColor(Color(UIColor.secondarySystemBackground))
          .aspectRatio(contentMode: .fill)
          .cornerRadius(4)
        ProgressView()
      }
      .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.35)))
    }
  }
}

#Preview {
  GroupCoverImageView(image: .constant(URL(string: "N/A")!))
}
