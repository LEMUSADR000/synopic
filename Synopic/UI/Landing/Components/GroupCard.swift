//
//  GroupCard.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/18/23.
//

import SwiftUI

struct GroupCard: View {
  let title: String
  let author: String
  let theme: Color
  let width: Double

  var body: some View {
    ZStack(alignment: .top) {
      Rectangle()
        .frame(height: width)
        .foregroundColor(.white)
      Rectangle()
        .frame(height: width * (2 / 3), alignment: .top)
        .foregroundColor(theme)
      VStack(alignment: .center) {
        VStack {
          if !title.isEmpty {
            Text(title.capitalized)
              .font(.headline.monospaced())
              .foregroundColor(.primary.opacity(0.6))
              .minimumScaleFactor(0.1)
              .multilineTextAlignment(.center)
          }
          if !author.isEmpty {
            Spacer().frame(height: 8)
            Text(author.capitalized)
              .font(.subheadline.monospaced())
              .foregroundColor(.primary.opacity(0.5))
              .minimumScaleFactor(0.1)
              .multilineTextAlignment(.center)
          }
        }.padding(2.5)
      }
      .frame(height: width * (2 / 3))
    }.frame(height: width)
  }
}

#Preview {
  GroupCard(
    title: "Author",
    author: "Author",
    theme: Color.generateRandomPastelColor(),
    width: 393
  )
}
