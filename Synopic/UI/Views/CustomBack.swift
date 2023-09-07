//
//  CustomBack.swift
//  Synopic
//
//  Created by Adrian Lemus on 9/1/23.
//

import SwiftUI
import Combine

struct CustomBack: View {
  init(action: @escaping () -> Void) {
    self.onTap = action
  }
  
  let onTap: () -> Void
  var body: some View {
    Button(
      action: onTap,
      label: {
        HStack {
          Image(systemName: "chevron.backward")
          Text("Back")
        }
      }
    )
  }
}

struct CustomBack_Previews: PreviewProvider {
  static var previews: some View {
    CustomBack(action: {})
  }
}
