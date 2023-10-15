//
//  HapticFeedbackProvider.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import SwiftUI
import UIKit

private let impactLightFeedbackGenerator: UIImpactFeedbackGenerator =
  .init(style: .light)
private let impactMediumFeedbackGenerator: UIImpactFeedbackGenerator =
  .init()
private let impactHeavyFeedbackGenerator: UIImpactFeedbackGenerator =
  .init(style: .heavy)
private let selectionFeedbackGenerator: UISelectionFeedbackGenerator =
  .init()
private let notificationFeedbackGenerator: UINotificationFeedbackGenerator =
  .init()

enum HapticFeedbackStyle {
  case impactLight
  case impactMedium
  case impactHeavy
  case selection
  case notifySuccess
  case notifyWarning
  case notifyError
}

protocol HapticFeedbackProvider {
  func hapticFeedback(_ style: HapticFeedbackStyle)
}

extension HapticFeedbackProvider {
  func hapticFeedback(_ style: HapticFeedbackStyle) {
    Self.hapticFeedback(style)
  }

  static func hapticFeedback(_ style: HapticFeedbackStyle) {
    DispatchQueue.main.async {
      switch style {
      case .impactLight: impactLightFeedbackGenerator.impactOccurred()
      case .impactMedium: impactMediumFeedbackGenerator.impactOccurred()
      case .impactHeavy: impactHeavyFeedbackGenerator.impactOccurred()
      case .selection: selectionFeedbackGenerator.selectionChanged()
      case .notifySuccess:
        notificationFeedbackGenerator.notificationOccurred(.success)
      case .notifyWarning:
        notificationFeedbackGenerator.notificationOccurred(.warning)
      case .notifyError:
        notificationFeedbackGenerator.notificationOccurred(.error)
      }
    }
  }
}

struct HapticFeedbackViewProxy: HapticFeedbackProvider {
  func generate(_ style: HapticFeedbackStyle) { Self.hapticFeedback(style) }
}

extension View {
  var haptics: HapticFeedbackViewProxy { HapticFeedbackViewProxy() }
}
