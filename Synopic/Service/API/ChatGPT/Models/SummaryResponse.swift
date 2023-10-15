//
//  SummaryResponse.swift
//  Synopic
//
//  Created by Adrian Lemus on 9/18/23.
//

import Foundation

// MARK: - Summary

struct SummaryResponse: Codable {
  let choices: [Choice]
  let created: Int
  let id, model, object: String
  let usage: Usage
}

// MARK: - Choice
<<<<<<< HEAD

struct Choice: Codable {
  let finishReason: String
  let index: Int
  let message: Message

=======
struct Choice: Codable {
  let finishReason: String
  let index: Int
  let message: Message

>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
  enum CodingKeys: String, CodingKey {
    case finishReason = "finish_reason"
    case index, message
  }
}

// MARK: - Message

struct Message: Codable {
  let content, role: String
}

// MARK: - Usage
<<<<<<< HEAD

struct Usage: Codable {
  let completionTokens, promptTokens, totalTokens: Int

=======
struct Usage: Codable {
  let completionTokens, promptTokens, totalTokens: Int

>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
  enum CodingKeys: String, CodingKey {
    case completionTokens = "completion_tokens"
    case promptTokens = "prompt_tokens"
    case totalTokens = "total_tokens"
  }
}
