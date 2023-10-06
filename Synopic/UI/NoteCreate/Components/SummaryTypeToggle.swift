//
//  SummaryTypeToggle.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/12/23.
//

import SwiftUI

struct SummaryTypeToggle: View {
  @Binding var model: SummaryType
  let type: SummaryType
  let action: () -> Void
  var body: some View {
    Button(
      action: action,
      label: {
        VStack {
          VStack(alignment: .center) {
            Image(systemName: imageName)
            Spacer().frame(height: 4)
            Text(desc)
              .font(.system(size: 12))
          }
          .frame(maxWidth: .infinity)
          .frame(height: 60)
        }
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(lineWidth: 3)
        )
      }
    )
    .foregroundColor(
      Color(
        self.model == type
          ? UIColor.systemBlue : UIColor.systemGray
      )
    )
  }

  private var imageName: String {
    switch self.type {
    case .sentence:
      return "text.line.first.and.arrowtriangle.forward"
    case .bullets:
      return "list.bullet"
    }
  }

  private var desc: String {
    switch self.type {
    case .sentence:
      return "Single Sentence"
    case .bullets:
      return "Three Points"
    }
  }
}

struct SummaryTypeToggle_Previews: PreviewProvider {
  static var previews: some View {
    SummaryTypeToggle(
      model: .constant(.bullets),
      type: .bullets,
      action: {}
    )
  }
}
