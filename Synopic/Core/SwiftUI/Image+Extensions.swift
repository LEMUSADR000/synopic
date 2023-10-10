//
//  Image+Extensions.swift
//  Synopic
//
//  Created by Adrian Lemus on 10/8/23.
//

import Foundation
import SwiftUI

extension Image {
  static func fromFile(from fileName: String) -> Image? {
    // TODO: Cache result of this if it appears to be an expensive operation
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(
      nsDocumentDirectory,
      nsUserDomainMask,
      true
    )

    if let dirPath = paths.first {
      let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
      if let image = UIImage(contentsOfFile: imageURL.path) {
        return Image(uiImage: image)
      }
    }

    return nil
  }
}
