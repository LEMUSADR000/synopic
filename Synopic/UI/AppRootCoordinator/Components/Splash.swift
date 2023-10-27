//
//  Splash.swift
//  Synopic
//
//  Created by adrian.lemus on 10/25/23.
//

import SwiftUI

struct Splash: View {
  var body: some View {
    ZStack {
      Rectangle()
        .background(.primary)
        .colorInvert()
      ColorSchemeAwareColorInverter {
        Image(uiImage: UIImage(named: "AppIconNoBackground") ?? UIImage())
          .resizable()
          .scaledToFit()
          .frame(width: 300, height: 300)
      }
      VStack {
        Spacer()
        Spacer().frame(height: 350)
        ColorSchemeAwareColorInverter {
          Text("synopic")
            .font(.system(size: 70, design: .rounded))
            .foregroundColor(Color(UIColor(red: 19 / 255, green: 20 / 255, blue: 27 / 255, alpha: 1)))
            .padding(.bottom, 20)
        }
        Spacer()
      }
    }
  }
}

#Preview {
  Splash()
}
