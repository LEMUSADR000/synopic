//
//  ViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Foundation

typealias ViewModelDefinition = (
  ObservableObject & Identifiable & Hashable & HapticFeedbackProvider
)

protocol ViewModel: ViewModelDefinition {}

extension ViewModel {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    lhs === rhs
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }
}
