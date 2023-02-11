//
//  NoteCreateViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/7/23.
//

import Combine
import Foundation
import Vision
import VisionKit

protocol NoteCreateViewModelDelegate: AnyObject {
  func noteCreateViewModelDidCancel(_ source: NoteCreateViewModel)
  func noteCreateViewModelDidProcessScan(_ source: NoteCreateViewModel)
  func noteCreateViewModelFailedToGenerateResult(_ source: NoteCreateViewModel)
}

public class NoteCreateViewModel: NSObject, ViewModel {
  private let ocrService: OCRService
  private weak var delegate: NoteCreateViewModelDelegate?
  private var cancelBag: CancelBag!

  init(ocrService: OCRService) { self.ocrService = ocrService }

  func setup(delegate: NoteCreateViewModelDelegate) -> Self {
    self.delegate = delegate
    bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()
    self.onScanReceived()
  }

  // MARK: EVENT

  let scanReceived: PassthroughSubject<VNDocumentCameraScan, Never> =
    PassthroughSubject()
  let toggleProcessMode: PassthroughSubject<ProcessType, Never> =
    PassthroughSubject()

  private func onScanReceived() {
    // TODO: Consider running this work in a background thread
    self.scanReceived
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        do {
          let output = try self.ocrService.processDocumentScan($0)
          self.content += output

          self.delegate?.noteCreateViewModelDidProcessScan(self)
        }
        catch {
          self.delegate?.noteCreateViewModelFailedToGenerateResult(self)
        }
      })
      .store(in: &self.cancelBag)
  }

  private func onToggleProcessMode() {
    self.toggleProcessMode
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        self.processType = $0
      })
      .store(in: &self.cancelBag)
  }

  // MARK: STATE
  @Published var content: String = .empty

  @Published var processType: ProcessType = .singleLine
}

enum ProcessType {
  case singleLine
  case bulleted
}

// MARK: VNDocumentCameraViewControllerDelegate

extension NoteCreateViewModel: VNDocumentCameraViewControllerDelegate {
  public func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFinishWith scan: VNDocumentCameraScan
  ) { self.scanReceived.send(scan) }

  public func documentCameraViewController(
    _ controller: VNDocumentCameraViewController,
    didFailWithError error: Error
  ) { self.delegate?.noteCreateViewModelDidCancel(self) }

  public func documentCameraViewControllerDidCancel(
    _ controller: VNDocumentCameraViewController
  ) { self.delegate?.noteCreateViewModelDidCancel(self) }
}
