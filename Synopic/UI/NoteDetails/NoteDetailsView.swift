//
//  NoteDetailsView.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/8/23.
//

import SwiftUI

struct NoteDetailsView: View {
  @ObservedObject var viewModel: NoteDetailsViewModel

  var body: some View { Text("Hello, World!") }
}

struct NoteDetailsView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(NoteDetailsViewModel.self)!

  static var previews: some View { NoteDetailsView(viewModel: viewModel) }
}
