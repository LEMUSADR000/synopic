//
//  GroupCard.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/18/23.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct GroupCard: View {
    
  let title: String
  let author: String
  let noteCount: Int
  let theme: Color
  let width: Double

  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Rectangle()
          .foregroundColor(theme)
        VStack {
          if !title.isEmpty {
            Text(title.capitalized)
              .font(.headline.monospaced())
              .foregroundColor(.black.opacity(0.6))
              .minimumScaleFactor(0.1)
              .multilineTextAlignment(.center)
          }
          if !author.isEmpty {
            Spacer().frame(height: 8)
            Text(author.capitalized)
              .font(.subheadline.monospaced())
              .foregroundColor(.black.opacity(0.5))
              .minimumScaleFactor(0.1)
              .multilineTextAlignment(.center)
          }
        }.padding(2.5)
      }
      .frame(height: width * (2 / 3))
      ZStack(alignment: .bottomTrailing) {
        Rectangle()
          .foregroundColor(.white)
        if noteCount > 0 {
          ZStack(alignment: .center) {
            Image(systemName: "note")
              .resizable()
              .foregroundColor(.black.opacity(0.5))
              .padding(5)
            Text("\(noteCount)")
              .font(.title.monospaced())
              .foregroundColor(.black.opacity(0.5))
              .padding(.top, width / 25)
              .padding(.bottom, width / 40)
              .padding(.horizontal, width / 40)
              .lineLimit(1)
              .minimumScaleFactor(0.1)
          }
          .frame(width: width / 6, height: width / 6)
          .padding(.trailing, width / 16)
          .padding(.bottom, width / 16)
        }
      }
    }.frame(height: width)
  }
}

#Preview {
  GroupCard(
    title: "Title",
    author: "Author",
    noteCount: 100,
    theme: Color.generateRandomPastelColor(),
    width: 393
  )
}
