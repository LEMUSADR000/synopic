//
//  LandingView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import SwiftUI

struct LandingView: View {
  @ObservedObject var viewModel: LandingViewModel

  var body: some View {
    List {
      ForEach(self.viewModel.sections) { section in
        Section {
          ForEach(section.items) { item in
            GroupRow(
              item: item,
              onTap: {
                self.viewModel.viewGroup.send(item.id)
              }
            )
            .transition(.move(edge: .leading))
          }
        } header: {
          Text(section.title)
        }
      }
    }
  }
}

struct LandingView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(LandingViewModel.self)!

  static var previews: some View {
    LandingView(viewModel: viewModel)
  }
}
