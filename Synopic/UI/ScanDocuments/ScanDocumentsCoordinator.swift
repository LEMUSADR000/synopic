//
//  ScanDocumentsCoordinator.swift
//  Synopic
//
//  Created by Adrian Lemus on 1/27/23.
//

import Foundation
import VisionKit
import Vision
import SwiftUI
import Swinject

class ScanDocumentsCoordinator: NSObject, VNDocumentCameraViewControllerDelegate, ViewModel {
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let extractedImages = extractImages(from: scan)
        let processedText = recognizeText(from: extractedImages)
        
        
        
        // TODO: Ferry data from the document scan result into a view model that is being used to track text to image - keep text combined with image
        
//        self.delegate?.scanDocumentsCoordinatorDidComplete(self)
    }
    
    fileprivate func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
        var extractedImages = [CGImage]()
        for index in 0..<scan.pageCount {
            let extractedImage = scan.imageOfPage(at: index)
            guard let cgImage = extractedImage.cgImage else { continue }
            
            extractedImages.append(cgImage)
        }
        return extractedImages
    }
    
    fileprivate func recognizeText(from images: [CGImage]) -> String {
        var entireRecognizedText = ""
        let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
            guard error == nil else { return }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            let maximumRecognitionCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else { continue }
                
                entireRecognizedText += "\(candidate.string)\n"
                
            }
        }
        recognizeTextRequest.recognitionLevel = .accurate
        
        for image in images {
            let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
            
            try? requestHandler.perform([recognizeTextRequest])
        }
        
        return entireRecognizedText
    }
}
