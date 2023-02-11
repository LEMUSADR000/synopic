//
//  SearchBar.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import SwiftUI

struct SearchBar: View {
  @State var text: String

  var body: some View {
    HStack {
      TextField("Search", text: $text).padding(7)
        .background(Color(UIColor.secondarySystemBackground)).cornerRadius(8)

      if !text.isEmpty {
        Button(
          action: { self.text = "" },
          label: {
            Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
          }
        )
      }
    }
  }
}

struct SearchBar_Previews: PreviewProvider {
  static var previews: some View { SearchBar(text: "") }
}
