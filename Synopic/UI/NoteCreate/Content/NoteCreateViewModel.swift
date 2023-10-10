//
//  NoteCreateViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/7/23.
//

import Combine
import CoreData
import Foundation
import Vision
import VisionKit

protocol NoteCreateViewModelDelegate: AnyObject {
  func noteCreateViewModelDidCancel(_ source: NoteCreateViewModel)
  func noteCreateViewModelDidProcessScan(_ source: NoteCreateViewModel)
  func noteCreateViewModelFailedToGenerate(error: Error, _ source: NoteCreateViewModel)
  func noteCreateViewModelGenerated(
    note: Note,
    _ source: NoteCreateViewModel
  )
}

public class NoteCreateViewModel: NSObject, ViewModel {
  private let ocrService: OCRService
  private let summariesRepository: SummariesRepository

  private weak var delegate: NoteCreateViewModelDelegate?
  private var cancelBag: CancelBag!

  init(ocrService: OCRService, summariesRepository: SummariesRepository) {
    self.ocrService = ocrService
    self.summariesRepository = summariesRepository
  }

  func setup(delegate: NoteCreateViewModelDelegate) -> Self {
    self.delegate = delegate
    self.bind()
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
      .receive(on: .global(qos: .userInitiated))
      .withLatestFrom(self.$content, self.$processType)
      .setFailureType(to: Error.self)
      .flatMapLatest { [weak self] content, processType -> AnyPublisher<Summary?, Error> in
        guard let self = self else {
          return Just<Summary?>(nil)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        }

        Task { @MainActor [weak self] in
          self?.isProcessing = true
        }

        return self.summariesRepository.requestSummary(text: content, type: processType)
          .map(Optional.some)
          .eraseToAnyPublisher()
      }
      .receive(on: .main)
      .sink(
        receiveValue: { [weak self] summary in
          guard let self = self, let summary = summary else { return }
          let note = Note(id: nil, created: summary.created, summary: summary.result)
          self.delegate?.noteCreateViewModelGenerated(note: note, self)
        },
        failure: { [weak self] error in
          guard let self = self else { return }
          self.delegate?.noteCreateViewModelFailedToGenerate(error: error, self)
        }
      )
      .store(in: &self.cancelBag)
  }

  private func onScanReceived() {
    // TODO: Consider running this work in a background thread
    self.scanReceived
      .setFailureType(to: Error.self)
      .receive(on: .global(qos: .userInitiated))
      .flatMap { scan -> AnyPublisher<String, Error> in
        Future<String, Error> { [weak self] promise in
          do {
            let processed = try self!.ocrService.processDocumentScan(scan)
            promise(.success(processed))
          } catch {
            promise(.failure(error))
          }
        }.eraseToAnyPublisher()
      }
      .receive(on: .main)
      .sink(
        receiveValue: { [weak self] summary in
          guard let self = self else { return }
          self.isProcessing = false
          self.content = summary
          self.delegate?.noteCreateViewModelDidProcessScan(self)
        },
        failure: { [weak self] error in
          guard let self = self else { return }
          self.isProcessing = false
          self.delegate?.noteCreateViewModelFailedToGenerate(error: error, self)
        }
      )
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
  @Published var processType: SummaryType = .sentence
  @Published var isProcessing: Bool = false
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
