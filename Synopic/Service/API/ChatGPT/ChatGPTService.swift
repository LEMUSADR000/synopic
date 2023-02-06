//
//  ChatGPTService.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Foundation
import Combine

protocol ChatGPTService {
    func makeRequest(prompt: String) async throws -> Data
}

class ChatGPTServiceImpl: ChatGPTService {
    private let token: String
    
    init(token: String) {
        self.token = token
    }
    
    func makeRequest(prompt: String) async throws -> Data {
        guard let endpoint = URL(string: "https://api.openai.com/v1/completions") else {
            throw ApiError.invalidURL
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Bearer \(token)")
        
        let body: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": "\(prompt)",
            "temperature": 0.7,
            "max_tokens": 60,
            "top_p": 1,
            "frequency_penalty": 0,
            "presence_penalty": 1
        ]
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ApiError.failedResponse("Invalid status code \(response)")
        }
        
        return data
    }
}
