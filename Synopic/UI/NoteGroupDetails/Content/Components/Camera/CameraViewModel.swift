//
//  CameraViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/10/23.
//

import AVFoundation
import Combine
import Foundation
import os.log
import SwiftUI
import UIKit

protocol CameraViewModelDelegate: AnyObject {
  func cameraViewDidSelectImage(image: CIImage, _ source: CameraViewModel)
}

final class CameraViewModel: ViewModel {
  // MARK: Dependencies

  private let camera: CameraService
  private weak var delegate: CameraViewModelDelegate?
  private var cancelBag: CancelBag!

  init(camera: CameraService) {
    self.camera = camera
  }

  func setup(delegate: CameraViewModelDelegate) -> Self {
    self.delegate = delegate
    self.bind()
    return self
  }

  private func bind() {
    self.cancelBag = CancelBag()
    self.registerButtonCallbacks()
  }

  // MARK: EVENTS

  let tapCameraButton: PassthroughSubject<CameraButtonTap, Never> = PassthroughSubject()

  private func registerButtonCallbacks() {
    self.tapCameraButton
      .sink(receiveValue: { [weak self] type in
        guard let self = self else { return }
        switch type {
        case .capture:
          self.camera.takePhoto()
          self.validatingImage = true
        case .accept:
          if let current = previewImage {
            self.delegate?.cameraViewDidSelectImage(image: current, self)
          }
        case .deny:
          self.validatingImage = false
        }
      })
      .store(in: &self.cancelBag)
  }

  private func checkAuthorization() async -> Bool {
    var authorized = false
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      
      authorized = true
    case .notDetermined:
      logger.debug("Camera access not determined.")
      authorized = await AVCaptureDevice.requestAccess(for: .video)
    case .denied:
      logger.debug("Camera access denied.")
    case .restricted:
      logger.debug("Camera library access restricted.")
      break
    @unknown default:
      break
    }

    return authorized
  }

  func start() async {
    guard await self.checkAuthorization() else {
      logger.error("Camera access failed to grant")
      return
    }

    self.camera.start()
      .receive(on: .main)
      .sink(receiveValue: { [weak self] ciImage in
        guard let self = self else { return }
        if !validatingImage {
          self.previewImage = ciImage
        }
      })
      .store(in: &self.cancelBag)
  }
  
  func stop() {
    return self.camera.stop()
  }

  // MARK: STATE

  @Published var previewImage: CIImage?
  @Published var validatingImage: Bool = false
}

enum CameraButtonTap {
  case accept
  case deny
  case capture
}

extension CIImage {
  var image: Image? {
    let ciContext = CIContext()
    guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
    return Image(decorative: cgImage, scale: 1, orientation: .up)
  }
}

private let logger = Logger(subsystem: "com.adriandevelopments.synopic", category: "CameraViewModel")
