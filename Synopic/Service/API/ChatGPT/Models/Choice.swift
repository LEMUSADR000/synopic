//
//  Choice.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/12/23.
//

import Foundation

struct Choice: Codable {
  let text: String
  let index: Int
  let logprobs: String?
  let finishReason: String

  enum CodingKeys: String, CodingKey {
    case text, index, logprobs
    case finishReason = "finish_reason"
  }
}
