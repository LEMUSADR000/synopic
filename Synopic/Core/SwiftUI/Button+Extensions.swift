//
//  Button+Extensions.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/24/22.
//

import SwiftUI
import Combine

extension Button {
  init(action: PassthroughSubject<Void, Never>, @ViewBuilder label: () -> Label) {
    self.init(action: { action.send() }, label: label)
  }
}
