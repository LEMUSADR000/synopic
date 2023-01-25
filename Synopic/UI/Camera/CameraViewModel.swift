//
//  CameraViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/18/22.
//

import Foundation
import AVFoundation
import SwiftUI
import os.log
import Combine

protocol CameraViewModelDelegate: AnyObject {
    
}

final class CameraViewModel: ViewModel {
    // MARK: Dependencies
    private let cameraService: CameraServiceProtocol
    private weak var delegate: CameraViewModelDelegate?
    private var cancelBag: CancelBag!
    
    init(cameraService: CameraServiceProtocol) {
        self.cameraService = cameraService
    }
    
    func setpup(delegate: CameraViewModelDelegate) -> Self {
        self.delegate = delegate
        bind()
        return self
    }
    
    private func bind() {
        self.cancelBag = CancelBag()
        self.registerButtonCallbacks()
    }
    
    // MARK: EVENTS
    let capturePhoto: PassthroughSubject<Void, Never> = PassthroughSubject()
    let acceptPhoto: PassthroughSubject<Void, Never> = PassthroughSubject()
    let denyPhoto: PassthroughSubject<Void, Never> = PassthroughSubject()
    
    private func registerButtonCallbacks() {
        self.capturePhoto
            .sink(receiveValue: { [weak self] in
                guard let self = self else { return }
                self.cameraService.takePhoto()
                self._validatingImage.send(true)
            })
            .store(in: &cancelBag)
        
        self.acceptPhoto
            .sink(receiveValue: {
                print("accept photo")
            })
            .store(in: &cancelBag)
        
        self.denyPhoto
            .sink(receiveValue: {[weak self] in
                guard let self = self else { return }
                self._validatingImage.send(false)
            })
            .store(in: &cancelBag)
    }
    
    private func checkAuthorization() async -> Bool {
        var authorized = false
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            logger.debug("Camera access authorized.")
            authorized = true
            break
        case .notDetermined:
            logger.debug("Camera access not determined.")
            authorized = await AVCaptureDevice.requestAccess(for: .video)
            break
        case .denied:
            logger.debug("Camera access denied.")
            break
        case .restricted:
            logger.debug("Camera library access restricted.")
            break
        @unknown default:
            break
        }
        
        return authorized
    }
    
    func start() async {
        guard await checkAuthorization() else {
            logger.error("Camera access failed to grant")
            return
        }
        
        self.cameraService.start()
            .receive(on: .main)
            .sink(receiveValue: { [weak self] ciImage in
                guard let self = self, !self._validatingImage.value else { return }
                if let preview = ciImage?.image {
                    self.previewImage = preview
                }
            })
            .store(in: &cancelBag)
    }
    
    // MARK: STATE
    @Published var previewImage: Image?
    
    private let _validatingImage: CurrentValueSubject<Bool, Never> = CurrentValueSubject(false)
    var validatingImage: AnyPublisher<Bool, Never> { self._validatingImage.eraseToAnyPublisher() }
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate let logger = Logger(subsystem: "com.adriandevelopments.synopic", category: "CameraViewModel")
