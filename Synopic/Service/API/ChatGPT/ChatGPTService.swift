//
//  ChatGPTService.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Combine
import Foundation

protocol ChatGPTService {
  func makeRequest(content: String, type: String) async throws -> SummaryResponse
}

class ChatGPTServiceImpl: ChatGPTService {
  private let token: String

  init(token: String) { self.token = token }

  func makeRequest(content: String, type: String) async throws -> SummaryResponse {
    guard let endpoint = URL(string: "https://saj9exv664.execute-api.us-west-2.amazonaws.com/summarize")
    else { throw ApiError.invalidURL }

    var request = URLRequest(url: endpoint)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let body: [String: Any] = [
      "type": type,
      "content": content
    ]
    let jsonData = try JSONSerialization.data(withJSONObject: body)

    request.httpBody = jsonData

    let (data, response) = try await URLSession.shared.data(for: request)

    guard (response as? HTTPURLResponse)?.statusCode == 200 else {
      print(response)
      throw ApiError.failedResponse("Invalid status code \(response)")
    }
    return try JSONDecoder().decode(SummaryResponse.self, from: data)
  }
}

enum SummaryType: String {
  case sentence = "sentence"
  case bullets = "bullets"
}
