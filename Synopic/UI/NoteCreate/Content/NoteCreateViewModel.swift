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
  func noteCreateViewModelFailedToGenerate(_ source: NoteCreateViewModel)
  func noteCreateViewModelGenerated(
    newNoteId: String,
    _ source: NoteCreateViewModel
  )
}

public class NoteCreateViewModel: NSObject, ViewModel {
  private let ocrService: OCRService
  private let summariesRepository: SummariesRepository
  private let groupId: ObjectIdentifier
  
  private weak var delegate: NoteCreateViewModelDelegate?
  private var cancelBag: CancelBag!

  init(ocrService: OCRService, summariesRepository: SummariesRepository, groupId: ObjectIdentifier) {
    self.ocrService = ocrService
    self.summariesRepository = summariesRepository
    self.groupId = groupId
  }

  func setup(delegate: NoteCreateViewModelDelegate) -> Self {
    self.delegate = delegate
    bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()
    self.onProcessText()
    self.onScanReceived()
    self.onToggleProcessMode()
  }

  // MARK: EVENT

  let processText: PassthroughSubject<Void, Never> =
    PassthroughSubject()
  let scanReceived: PassthroughSubject<VNDocumentCameraScan, Never> =
    PassthroughSubject()
  let toggleProcessMode: PassthroughSubject<SummaryType, Never> =
    PassthroughSubject()

  private func onProcessText() {
    self.processText
      .receive(on: .main)
      .subscribe(on: .global(qos: .userInitiated))
      .asyncSink(receiveValue: { [weak self] in
        guard let self = self else { return }

        do {
          _ = try await self.summariesRepository.createNote(
            parentId: self.groupId,
            text: self.content,
            type: self.processType
          )
        }
        catch {
          self.delegate?.noteCreateViewModelFailedToGenerate(self)
        }
      })
      .store(in: &self.cancelBag)
  }

  private func onScanReceived() {
    // TODO: Consider running this work in a background thread
    self.scanReceived
      .sink(receiveValue: { [weak self] in
        guard let self = self else { return }
        do {
          self.content = try self.ocrService.processDocumentScan($0)

          self.delegate?.noteCreateViewModelDidProcessScan(self)
        }
        catch {
          self.delegate?.noteCreateViewModelFailedToGenerate(self)
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

  @Published var processType: SummaryType = .singleSentence
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
