//
//  SummariesRepository.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Combine
import Foundation

enum SummaryType: String {
  case singleSentence = "a sentence"
  case threePoints = "three points"
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
    let prompt = "Summarize the following into \(type.rawValue): \(text)"

    let summary: Summary
    do {
      let result = try await chatGptApiService.makeRequest(prompt: prompt)
      summary = try JSONDecoder().decode(Summary.self, from: result)
    }
    catch { throw error }

    return summary
  }
}
