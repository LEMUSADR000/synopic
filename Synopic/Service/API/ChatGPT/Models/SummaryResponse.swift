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
struct Choice: Codable {
    let finishReason: String
    let index: Int
    let message: Message

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
struct Usage: Codable {
    let completionTokens, promptTokens, totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case completionTokens = "completion_tokens"
        case promptTokens = "prompt_tokens"
        case totalTokens = "total_tokens"
    }
}
