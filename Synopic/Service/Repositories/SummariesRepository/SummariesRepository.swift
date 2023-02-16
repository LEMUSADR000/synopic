//
//  SummariesRepository.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Combine
import Foundation

enum SummaryType: String {
  case singleSentence = "Summarize the following into a sentence"
  case threePoints = "Summarize the following into three points"
}

protocol SummariesRepository {

  func requestSummary(text: String, type: SummaryType) async throws -> Summary
}

class SummariesRepositoryImpl: SummariesRepository {
  // TODO: Associate a loading function which fetches local storage

  private let chatGptApiService: ChatGPTService

  init(chatGptApiService: ChatGPTService) {
    self.chatGptApiService = chatGptApiService
  }

  func requestSummary(text: String, type: SummaryType) async throws -> Summary
  {
    // TODO: Explore better (shorter, more accurate, etc) prompts i.e.: `Extreme TLDR`
    let prompt = type.rawValue

    let summary: Summary
    do {
      let result = try await chatGptApiService.makeRequest(prompt: prompt)
      guard !result.choices.isEmpty else {
        throw SummariesError.requestFailed("No choices found in result")
      }
      summary = Summary(id: result.id, result: result.choices.first!.text)
    }
    catch { throw error }

    return summary
  }
}

enum SummariesError: Error {
  case requestFailed(String)
}
