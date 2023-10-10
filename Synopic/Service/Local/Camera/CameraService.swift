//
//  CameraService.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/8/22.
//

import AVFoundation
import Combine
import os.log
import SwiftUI
import UIKit

protocol CameraService: AnyObject {
  func start() -> AnyPublisher<CIImage?, Never>
  func stop()
  func switchCaptureDevice()
  func takePhoto()
}

class CameraServiceImpl: NSObject, CameraService {
  private let cameraManager: CameraManager
  private let captureSession: AVCaptureSession
  private var deviceInput: AVCaptureDeviceInput?
  private var photoOutput: AVCapturePhotoOutput?
  private var videoOutput: AVCaptureVideoDataOutput?
  private var sessionQueue: DispatchQueue

  init(cameraManager: CameraManager) {
    self.cameraManager = cameraManager
    self.captureSession = AVCaptureSession()
    self.sessionQueue = DispatchQueue(label: "session queue")

    super.init()
  }

  // MARK: Service Operations

  private let _previewStream: CurrentValueSubject<CIImage?, Never> = CurrentValueSubject(nil)
  func start() -> AnyPublisher<CIImage?, Never> {
    sessionQueue.async { [self] in
      if !self.captureSession.isRunning {
        self.configureCaptureSession { configurationDidSucceed in
          if configurationDidSucceed {
            self.captureSession.startRunning()
          } else {
            logger.error("Failed to configure camera session!")
          }
        }
      } else {
        logger.error("Camera session was already running")
      }
    }

    return _previewStream.eraseToAnyPublisher()
  }

  func stop() {
    sessionQueue.async {
      self.captureSession.stopRunning()
    }
  }

  func switchCaptureDevice() {
    if let captureDevice = cameraManager.captureDevice, let index = cameraManager.availableCaptureDevices.firstIndex(of: captureDevice) {
      let nextIndex = (index + 1) % cameraManager.availableCaptureDevices.count
      self.captureDevice = cameraManager.availableCaptureDevices[nextIndex]
    } else {
      captureDevice = AVCaptureDevice.default(for: .video)
    }
  }

  func takePhoto() {
    guard let photoOutput = photoOutput else { return }

    sessionQueue.async {
      var photoSettings = AVCapturePhotoSettings()

      if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
        photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
      }

      let isFlashAvailable = self.deviceInput?.device.isFlashAvailable ?? false
      photoSettings.flashMode = isFlashAvailable ? .auto : .off
      photoSettings.isHighResolutionPhotoEnabled = true
      if let previewPhotoPixelFormatType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
        photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
      }
      photoSettings.photoQualityPrioritization = .balanced

      if let photoOutputVideoConnection = photoOutput.connection(with: .video) {
        if photoOutputVideoConnection.isVideoOrientationSupported,
           let videoOrientation = self.videoOrientationFor(self.deviceOrientation)
        {
          photoOutputVideoConnection.videoOrientation = videoOrientation
        }
      }

      photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
  }

  // MARK: PRIVATE

  private var captureDevice: AVCaptureDevice? {
    didSet {
      guard let captureDevice = captureDevice else { return }
      logger.debug("Using capture device: \(captureDevice.localizedName)")
      sessionQueue.async {
        self.updateSessionForCaptureDevice(captureDevice)
      }
    }
  }

  private func configureCaptureSession(completionHandler: (_ configurationDidSucceed: Bool) -> Void) {
    var configurationDidSucceed = false
    captureSession.beginConfiguration()

    defer {
      self.captureSession.commitConfiguration()
      completionHandler(configurationDidSucceed)
    }

    guard
      let captureDevice = cameraManager.captureDevice,
      let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
    else {
      logger.error("Failed to obtain video input.")
      return
    }

    let photoOutput = AVCapturePhotoOutput()

    captureSession.sessionPreset = AVCaptureSession.Preset.photo

    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoDataOutputQueue"))

    guard captureSession.canAddInput(deviceInput) else {
      logger.error("Unable to add device input to capture session.")
      return
    }
    guard captureSession.canAddOutput(photoOutput) else {
      logger.error("Unable to add photo output to capture session.")
      return
    }
    guard captureSession.canAddOutput(videoOutput) else {
      logger.error("Unable to add video output to capture session.")
      return
    }

    captureSession.addInput(deviceInput)
    captureSession.addOutput(photoOutput)
    captureSession.addOutput(videoOutput)

    self.deviceInput = deviceInput
    self.photoOutput = photoOutput
    self.videoOutput = videoOutput

    photoOutput.isHighResolutionCaptureEnabled = true
    photoOutput.maxPhotoQualityPrioritization = .quality

    updateVideoOutputConnection()
    configurationDidSucceed = true
  }

  private func deviceInputFor(device: AVCaptureDevice?) -> AVCaptureDeviceInput? {
    guard let validDevice = device else { return nil }
    do {
      return try AVCaptureDeviceInput(device: validDevice)
    } catch {
      logger.error("Error getting capture device input: \(error.localizedDescription)")
      return nil
    }
  }

  private func updateSessionForCaptureDevice(_ captureDevice: AVCaptureDevice) {
    captureSession.beginConfiguration()
    defer { captureSession.commitConfiguration() }

    for input in captureSession.inputs {
      if let deviceInput = input as? AVCaptureDeviceInput {
        captureSession.removeInput(deviceInput)
      }
    }

    if let deviceInput = deviceInputFor(device: captureDevice) {
      if !captureSession.inputs.contains(deviceInput), captureSession.canAddInput(deviceInput) {
        captureSession.addInput(deviceInput)
      }
    }

    updateVideoOutputConnection()
  }

  private func updateVideoOutputConnection() {
    if let videoOutput = videoOutput, let videoOutputConnection = videoOutput.connection(with: .video) {
      if videoOutputConnection.isVideoMirroringSupported {
        videoOutputConnection.isVideoMirrored = isUsingFrontCaptureDevice
      }
    }
  }

  private var isUsingFrontCaptureDevice: Bool {
    guard let captureDevice = cameraManager.captureDevice else { return false }
    return cameraManager.frontCaptureDevices.contains(captureDevice)
  }

  private var isUsingBackCaptureDevice: Bool {
    guard let captureDevice = cameraManager.captureDevice else { return false }
    return cameraManager.backCaptureDevices.contains(captureDevice)
  }
}

extension CameraServiceImpl: AVCapturePhotoCaptureDelegate {
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error = error {
      logger.error("Error capturing photo: \(error.localizedDescription)")
      return
    }

    guard let pixelBuffer = photo.pixelBuffer else { return }
    _previewStream.send(CIImage(cvPixelBuffer: pixelBuffer))
  }
}

extension CameraServiceImpl: AVCaptureVideoDataOutputSampleBufferDelegate {
  private var deviceOrientation: UIDeviceOrientation {
    var orientation = UIDevice.current.orientation
    if orientation == UIDeviceOrientation.unknown {
      orientation = UIScreen.main.orientation
    }
    return orientation
  }

  private func videoOrientationFor(_ deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation? {
    switch deviceOrientation {
    case .portrait: return AVCaptureVideoOrientation.portrait
    case .portraitUpsideDown: return AVCaptureVideoOrientation.portraitUpsideDown
    case .landscapeLeft: return AVCaptureVideoOrientation.landscapeRight
    case .landscapeRight: return AVCaptureVideoOrientation.landscapeLeft
    default: return nil
    }
  }

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    if connection.isVideoOrientationSupported, let videoOrientation = videoOrientationFor(deviceOrientation) {
      connection.videoOrientation = videoOrientation
    }

    guard let pixelBuffer = sampleBuffer.imageBuffer else { return }
    _previewStream.send(CIImage(cvPixelBuffer: pixelBuffer))
  }
}

private extension UIScreen {
  var orientation: UIDeviceOrientation {
    let point = coordinateSpace.convert(CGPoint.zero, to: fixedCoordinateSpace)
    if point == CGPoint.zero {
      return .portrait
    } else if point.x != 0 && point.y != 0 {
      return .portraitUpsideDown
    } else if point.x == 0 && point.y != 0 {
      return .landscapeRight
    } else if point.x != 0 && point.y == 0 {
      return .landscapeLeft
    } else {
      return .unknown
    }
  }
}

private let logger = Logger(subsystem: "com.adriandevelopments.synopic", category: "CameraService")
