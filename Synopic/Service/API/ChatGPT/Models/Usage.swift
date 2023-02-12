//
//  Usage.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/12/23.
//

import Foundation

struct Usage: Codable {
  let promptTokens, completionTokens, totalTokens: Int

  enum CodingKeys: String, CodingKey {
    case promptTokens = "prompt_tokens"
    case completionTokens = "completion_tokens"
    case totalTokens = "total_tokens"
  }
}
