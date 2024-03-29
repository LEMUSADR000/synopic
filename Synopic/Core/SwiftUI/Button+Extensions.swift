//
//  Button+Extensions.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/24/22.
//

import Combine
import SwiftUI

extension Button {
  init(
    action: PassthroughSubject<Void, Never>,
    @ViewBuilder label: () -> Label
  ) { self.init(action: { action.send() }, label: label) }
  
  @inlinable init(
    action: PassthroughSubject<Void, Never>,
    @ViewBuilder _ label: @escaping () -> Label
  ) { self.init(action: { action.send() }, label: label) }
}
