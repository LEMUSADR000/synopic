//
//  Completions.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/12/23.
//

import Foundation

struct Completions: Codable {
  let id, object: String
  let created: Int
  let model: String
  let choices: [Choice]
  let usage: Usage
}
