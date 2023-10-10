//
//  CameraManager.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/8/23.
//

import AVFoundation
import CoreImage
import os.log

class CameraManager {
  private let allCaptureDevices: [AVCaptureDevice]
  var captureDevice: AVCaptureDevice? {
    availableCaptureDevices.first ?? AVCaptureDevice.default(for: .video)
  }

  init() {
    allCaptureDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera, .builtInDualWideCamera], mediaType: .video, position: .unspecified).devices
  }

  var frontCaptureDevices: [AVCaptureDevice] {
    allCaptureDevices
      .filter { $0.position == .front }
  }

  var backCaptureDevices: [AVCaptureDevice] {
    allCaptureDevices
      .filter { $0.position == .back }
  }

  var captureDevices: [AVCaptureDevice] {
    var devices = [AVCaptureDevice]()

    if let backDevice = backCaptureDevices.first {
      devices += [backDevice]
    }
    if let frontDevice = frontCaptureDevices.first {
      devices += [frontDevice]
    }

    return devices
  }

  var availableCaptureDevices: [AVCaptureDevice] {
    captureDevices
      .filter { $0.isConnected }
      .filter { !$0.isSuspended }
  }
}

private let logger = Logger(subsystem: "com.adriandevelopments.synopic", category: "CameraManager")
