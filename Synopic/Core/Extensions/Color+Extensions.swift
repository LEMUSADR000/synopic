//
//  Color+Extensions.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/17/23.
//

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
}
