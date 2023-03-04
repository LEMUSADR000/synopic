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
  var groups: AnyPublisher<[Group], Never> { get }
  var notes: AnyPublisher<[String: [Note]], Never> { get }
  func load() async
  func createNote(groupId: String, text: String, type: SummaryType)
    async throws
}

class SummariesRepositoryImpl: SummariesRepository {
  // TODO: Associate a loading function which fetches local storage

  private let chatGptApiService: ChatGPTService

  init(chatGptApiService: ChatGPTService) {
    self.chatGptApiService = chatGptApiService
  }

  private let _groups: CurrentValueSubject<[Group], Never> =
    CurrentValueSubject([])
  var groups: AnyPublisher<[Group], Never> {
    self._groups.eraseToAnyPublisher()
  }

  private let _notes: CurrentValueSubject<[String: [Note]], Never> =
    CurrentValueSubject(
      [:])
  var notes: AnyPublisher<[String: [Note]], Never> {
    self._notes.eraseToAnyPublisher()
  }

  func load() async {
    try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second

    let today = Date()
    let gIds = [
      ["Lion's King", "James"],
      ["Enders Game", "Bernard"],
      ["Star Wars", "Xander"],
      ["Lion's Witch", "Gertrude"],
      ["One Piece", "Clint"],
      ["Ronaldo", "Ronaldo"],
      ["Clintonail Pt 2", "Clint"],
      ["Randall's Wine", "Dwinles"],
      ["Great Reservation", "Chines"],
    ]

    var g: [Group] = []
    for (index, names) in gIds.enumerated() {
      let id = UUID().uuidString

      let date = today.adding(days: -index)

      g.append(Group(id: id, created: date, title: names[0], author: names[1]))
    }
    self._groups.send(g)

    var n: [String: [Note]] = [:]
    for _group in g {
      n[_group.id] = [
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "note1",
          groupId: _group.id
        ),
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "note2",
          groupId: _group.id
        ),
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "note3",
          groupId: _group.id
        ),
      ]
    }

    self._notes.send(n)
  }

  func createNote(groupId: String, text: String, type: SummaryType)
    async throws
  {
    let summary = try await requestSummary(text: text, type: type)
    let note = Note(
      id: summary.id,
      created: summary.created,
      summary: summary.result,
      groupId: groupId
    )

    var notes = _notes.value
    if var notesForId = notes[groupId] {
      notesForId.append(note)
      notes[groupId] = notesForId
    }
    else {
      notes[groupId] = [note]
    }

    _notes.send(notes)
  }

  // MARK: Private Utility

  private func requestSummary(text: String, type: SummaryType) async throws
    -> Summary
  {
    // TODO: Explore better (shorter, more accurate, etc) prompts i.e.: `Extreme TLDR`
    let prompt = type.rawValue

    let result = try await chatGptApiService.makeRequest(prompt: prompt)
    guard !result.choices.isEmpty else {
      throw SummariesError.requestFailed("No choices found in result")
    }

    return Summary(
      id: result.id,
      result: result.choices.first!.text,
      created: Date.init(timeIntervalSince1970: TimeInterval(result.created))
    )
  }
}

enum SummariesError: Error {
  case requestFailed(String)
}
