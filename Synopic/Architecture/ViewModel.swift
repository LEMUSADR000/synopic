//
//  ViewModel.swift
//  Synopic
//
//  Created by Adrian Lemus on 12/20/22.
//

import Foundation

typealias ViewModelDefinition = (
  ObservableObject & Identifiable & HapticFeedbackProvider
)

protocol ViewModel: ViewModelDefinition {}
