//
//  ChatGPTService.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Combine
import Foundation

protocol ChatGPTService {
  func makeRequest(prompt: String) async throws -> SummaryResponse
}

class ChatGPTServiceImpl: ChatGPTService {
  private let token: String

  init(token: String) { self.token = token }

  func makeRequest(prompt: String) async throws -> SummaryResponse {
    guard let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")
    else { throw ApiError.invalidURL }

    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

    let body: [String: Any] = [
      "model": "gpt-3.5-turbo",
      "messages": [
        [
          "role": "system",
          "content": prompt
        ]
      ],
      "temperature": 0,
      "max_tokens": 256,
      "top_p": 1,
      "frequency_penalty": 2,
      "presence_penalty": 0,
    ]
    let jsonData = try JSONSerialization.data(withJSONObject: body)

    request.httpBody = jsonData

    let (data, response) = try await URLSession.shared.data(for: request)

    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      throw ApiError.failedResponse("Invalid status code \(response)")
    }
    return try JSONDecoder().decode(SummaryResponse.self, from: data)
  }
}
