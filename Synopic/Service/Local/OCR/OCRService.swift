//
//  OCRService.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/29/23.
//

import Combine
import Foundation
import OSLog
import Vision
import VisionKit

protocol OCRService: AnyObject {
  var canScan: AnyPublisher<Bool?, Never> { get }

  func processDocumentScan(_ scan: VNDocumentCameraScan) throws -> String
}

class OCRServiceImpl: NSObject, OCRService {
  override init() {
    self.cancelBag = CancelBag()
    super.init()
  }

  // MARK: Public
  lazy private(set) var canScan: AnyPublisher<Bool?, Never> = self._canScan
    .eraseToAnyPublisher()

  func processDocumentScan(_ scan: VNDocumentCameraScan) throws -> String {
    var combinedOutput = ""
    for index in 0..<scan.pageCount {
      let extractedImage = scan.imageOfPage(at: index)

      guard let cgImage = extractedImage.cgImage else {
        logger.log("Failed to retrieve cgImage from extracted scan")
        continue
      }

      do {
        let textRequest = try perform(request, on: cgImage)
        combinedOutput += try postProcess(request: textRequest)
      } catch {
        logger.log("Encountered exception on processing of document scan")
        continue
      }
    }

    // Should we bubble up any other exceptions?
    if combinedOutput.isEmpty { throw OCRError.noTextFound }

    return combinedOutput
  }

  // MARK: Private Members & Utility
  private var cancelBag: CancelBag

  private let _canScan: CurrentValueSubject<Bool?, Never> =
    CurrentValueSubject(nil)

  private lazy var request: VNRecognizeTextRequest = {
    let req = VNRecognizeTextRequest()
    return req
  }()

  private func perform(_ request: VNRequest, on image: CGImage) throws
    -> VNRequest
  {
    let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
    try requestHandler.perform([request])
    return request
  }

  private func postProcess(request: VNRequest) throws -> String {
    guard let observations = request.results as? [VNRecognizedTextObservation]
    else {
      logger.log("Failed to retrieve observations from request results")
      throw OCRError.noObservations
    }

    var entireRecognizedText = ""
    for observation in observations {
      guard
        let candidate = observation.topCandidates(maxRecognitionCandidates)
          .first
      else {
        logger.log("Failed to generate a candidate for observation")
        continue
      }

      entireRecognizedText += "\(candidate.string)\n"
    }

    return entireRecognizedText
  }
}

private let maxRecognitionCandidates = 1

private let logger = Logger(
  subsystem: "com.adriandevelopments.synopic",
  category: "OCRService"
)

enum OCRError: Error {
  case noTextFound
  case cgImageMissing
  case noCandidates
  case noObservations
  case error(Error?)
}
