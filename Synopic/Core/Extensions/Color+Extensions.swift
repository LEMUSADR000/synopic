//
//  Color+Extensions.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/17/23.
//

import SwiftUI
import UIKit

extension UIColor {
  func saturated(by factor: CGFloat) -> UIColor {
    var hue: CGFloat = 0
    var saturation: CGFloat = 0
    var brightness: CGFloat = 0
    var alpha: CGFloat = 0

    getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

    saturation = max(0, min(1, saturation + factor))

    return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
  }

  func mixed(with color: UIColor) -> UIColor {
    var red1: CGFloat = 0
    var green1: CGFloat = 0
    var blue1: CGFloat = 0
    var alpha1: CGFloat = 0

    var red2: CGFloat = 0
    var green2: CGFloat = 0
    var blue2: CGFloat = 0
    var alpha2: CGFloat = 0

    getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
    color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

    let mixedRed = (red1 + red2) / 2
    let mixedGreen = (green1 + green2) / 2
    let mixedBlue = (blue1 + blue2) / 2

    return UIColor(red: mixedRed, green: mixedGreen, blue: mixedBlue, alpha: (alpha1 + alpha2) / 2)
  }

  var hexString: String {
    let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!, intent: .defaultIntent, options: nil)!
    let colorRef = cgColorInRGB.components
    let r = colorRef?[0] ?? 0
    let g = colorRef?[1] ?? 0
    let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
    let a = cgColor.alpha

    var color = String(
      format: "#%02lX%02lX%02lX",
      lroundf(Float(r * 255)),
      lroundf(Float(g * 255)),
      lroundf(Float(b * 255))
    )

    if a < 1 {
      color += String(format: "%02lX", lroundf(Float(a * 255)))
    }

    return color
  }

  fileprivate static var randomCGFloat: CGFloat {
    CGFloat.random(in: 0 ... 1)
  }

  static func generateRandomPastelColor() -> UIColor {
    var randomColor = UIColor(red: self.randomCGFloat, green: self.randomCGFloat, blue: self.randomCGFloat, alpha: 1.0)

    // Saturate the color by 10%
    randomColor = randomColor.saturated(by: 0.01)

    // Mix with white
    randomColor = randomColor.mixed(with: UIColor.white)

    return randomColor
  }
}

extension Color {
  static func generateRandomPastelColor() -> Color {
    Color(UIColor.generateRandomPastelColor())
  }
}

extension CGColor {
  static func generateRandomPastelColor() -> CGColor {
    UIColor.generateRandomPastelColor().cgColor
  }
}
