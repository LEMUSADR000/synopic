//
//  ScanDocumentsView.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/25/23.
//

import SwiftUI
import Vision
import VisionKit

struct ScanDocumentsView: UIViewControllerRepresentable {
  let noteCreateViewModel: NoteCreateViewModel

  func makeCoordinator() -> NoteCreateViewModel { noteCreateViewModel }

  func makeUIViewController(context: Context) -> VNDocumentCameraViewController
  {
    // TODO: Figure out how to delay creatin of VNDocumentCameraViewController in order to check if scanning is supported on running device
    let documentViewController = VNDocumentCameraViewController()
    documentViewController.delegate = context.coordinator
    return documentViewController
  }

  func updateUIViewController(
    _ uiViewController: VNDocumentCameraViewController,
    context: Context
  ) {}
}

struct ScanDocumentsView_Previews: PreviewProvider {
  static let appAssembler = AppAssembler()
  static let viewModel = appAssembler.resolve(NoteCreateViewModel.self)!

  static var previews: some View {
    ScanDocumentsView(noteCreateViewModel: viewModel)
  }
}
