//
//  ApiErrors.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Foundation

enum ApiError: Error {
  case invalidURL
  case failedResponse(String)
}
