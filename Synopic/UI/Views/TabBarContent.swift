//
//  TabBarContent.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/5/23.
//

import SwiftUI

struct TabBarContent: View {
  var viewModel: LandingViewModel

  var body: some View {
    HStack(alignment: .center) {
      Spacer().frame(maxWidth: .infinity, alignment: .leading)

      // TODO: Create & replace this Text view with one which tracks note count
      Text("Notes").font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .center)

      Button(
        action: {
          self.viewModel.createGroup.send()
        },
        label: {
          Image(systemName: "rectangle.and.pencil.and.ellipsis")
            .foregroundColor(Color(UIColor.systemGray))
            .padding()
        }
      )
      .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }
}

struct TabBarContent_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(LandingViewModel.self)!

  static var previews: some View { TabBarContent(viewModel: viewModel) }
}
