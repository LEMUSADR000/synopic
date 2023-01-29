//
//  OCRService.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/29/23.
//

import OSLog
import Foundation
import Combine
import VisionKit
import Vision

protocol OCRServiceProtocol: AnyObject {
    var canScan: AnyPublisher<Bool?, Never> { get }
    var documentScanResults: AnyPublisher<DocumentScanResult?, Never> { get }
    
    func processDocumentScan(_ scan: VNDocumentCameraScan)
}

class OCRService: NSObject, OCRServiceProtocol {
    // MARK: Public API
    
    lazy private(set) var canScan: AnyPublisher<Bool?, Never> = self._canScan.eraseToAnyPublisher()
    
    lazy private(set) var documentScanResults: AnyPublisher<DocumentScanResult?, Never> = self._documentScanResults.eraseToAnyPublisher()
    
    override init() {
        self.cancelBag = CancelBag()
        super.init()
    }
    
    func processDocumentScan(_ scan: VNDocumentCameraScan) {
        // TODO: Because we assume life cycle of OCRService will likely be encapsulating any life cycle of call-ees, unowned seems right here - BUT, let's be careful because this can cause crashes if instance is no longer available
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            for index in 0..<scan.pageCount {
                let extractedImage = scan.imageOfPage(at: index)

                guard let cgImage = extractedImage.cgImage else {
                    logger.log("Failed to retrieve cgImage from extracted scan")
                    continue
                }
                
                let imageRequestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                
                let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
                    guard error == nil else {
                        logger.log("Encountered \(error) on VNRecognizeTextRequest")
                        return
                    }
                    
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        logger.log("Failed to retrieve observations from request results")
                        return
                    }
                    
                    var entireRecognizedText = ""
                    
                    for observation in observations {
                        guard let candidate = observation.topCandidates(MAX_RECOGNITION_CANDIDATES).first else {
                            logger.log("Failed to generate a candidate for scan")
                            return
                        }
                        
                        entireRecognizedText += "\(candidate.string)\n"
                    }
                    
                    self._documentScanResults.send(DocumentScanResult(image: extractedImage, text: entireRecognizedText))
                }
                
                do {
                    try imageRequestHandler.perform([recognizeTextRequest])
                } catch {
                    logger.log("Failed to generate a candidate for scan")
                }
            }
        }
    }
    
    // MARK: Private Members & Utility
    private var cancelBag: CancelBag
    
    private let _canScan: CurrentValueSubject<Bool?, Never> = CurrentValueSubject(nil)
    
    private let _documentScanResults: CurrentValueSubject<DocumentScanResult?, Never> = CurrentValueSubject(nil)
}

fileprivate let MAX_RECOGNITION_CANDIDATES = 1

fileprivate let logger = Logger(subsystem: "com.adriandevelopments.synopic", category: "OCRService")
