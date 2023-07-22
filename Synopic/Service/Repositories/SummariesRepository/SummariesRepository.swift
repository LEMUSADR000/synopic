//
//  SummariesRepository.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Combine
import CombineExt
import Foundation

enum SummaryType: String {
  case singleSentence = "Summarize the following into a sentence"
  case threePoints = "Summarize the following into three points"
}

protocol SummariesRepository {
  var groups: AnyPublisher<[String: Group], Never> { get }
  var notes: AnyPublisher<[String: [Note]], Never> { get }

  func loadGroups() -> AnyPublisher<[String: Group], Never>
  func loadNotes() -> AnyPublisher<[String: [Note]], Never>

  @discardableResult func createNote(
    groupId: String,
    text: String,
    type: SummaryType
  )
    async throws -> String

  @discardableResult func updateGroup(
    id: String,
    title: String,
    author: String
  ) async throws
    -> Group?
}

class SummariesRepositoryImpl: SummariesRepository {
  private var cancelBag: CancelBag
  private let chatGptApiService: ChatGPTService
  private let persistentStore: PersistentStore

  init(chatGptApiService: ChatGPTService, persistentStore: PersistentStore) {
    self.chatGptApiService = chatGptApiService
    self.persistentStore = persistentStore
    self.cancelBag = CancelBag()
  }

  nonisolated var notes: AnyPublisher<[String: [Note]], Never> {
    notesCache.publisher
  }

  nonisolated var groups: AnyPublisher<[String: Group], Never> {
    groupsCache.publisher
  }

  func loadGroups() -> AnyPublisher<[String: Group], Never> {
    Task { [unowned self] in
      try? await self.fetchGroups()
    }

    return self.groupsCache.publisher
  }


  func loadNotes() -> AnyPublisher<[String: [Note]], Never> {
    Task { [unowned self] in
      try? await self.fetchNotes()
    }

    return self.notesCache.publisher
  }

  func updateGroup(id: String, title: String, author: String) async throws
    -> Group?
  {
    guard !title.isEmpty && !author.isEmpty else {
      if await self.notesCache.value[id]?.isEmpty != true {
        await self.groupsCache.removeValue(forKey: id)
        // TODO: Delete from persistent storage
      }
      
      return nil
    }
    
    var group: Group? = await self.groupsCache.value[id]
    if group == nil {
      group = persistentStore.create
    }
        
    if await self.notesCache.value[id]?.isEmpty != false && title.isEmpty && author.isEmpty {
      await self.groupsCache.removeValue(forKey: id)
      return nil
    }
    
    var group: Group? = nil
    if let stored = await self.groupsCache.value[id] {
      group = stored
      group?.lastEdited = Date()
      group?.title = title
      group?.author = author
    } else {
      group = Group(
        id: id,
        lastEdited: Date(),
        title: title,
        author: author
      )
    }
    
    group = await self.groupsCache.setValue(group, forKey: group.id)
    
    return group
  }

  func createNote(groupId: String, text: String, type: SummaryType)
    async throws -> String
  {
    let summary = try await requestSummary(text: text, type: type)
    let note = Note(
      id: summary.id,
      created: summary.created,
      summary: summary.result,
      groupId: groupId
    )

    let notes: [Note]
    if var notesForId = await self.notesCache.getValue(forKey: groupId) {
      notesForId.append(note)
      notes = notesForId
    }
    else {
      notes = [note]
    }

    await self.notesCache.setValue(notes, forKey: groupId)

    return note.id
  }

  // Mark: - Private API

  private let groupsCache = Cache<String, Group>()
  private let notesCache = Cache<String, [Note]>()

  private func fetchGroups() async throws {
    let value = await _loadGroups()
    await self.groupsCache.addAll(value)
  }

  private func _loadGroups() async -> [String: Group] {
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

    var g: [String: Group] = [:]
    for (index, names) in gIds.enumerated() {
      let id = "\(index)"

      let date = today.adding(days: -index)

      g[id] = Group(
        id: id,
        lastEdited: date,
        title: names[0],
        author: names[1]
      )
    }

    return g
  }

  private func fetchNotes() async throws {
    let value = await _loadNotes()
    await self.notesCache.addAll(value)
  }

  private func _loadNotes() async -> [String: [Note]] {
    var n: [String: [Note]] = [:]
    for id in ["0", "1", "2", "3", "4", "5", "6", "7", "8"] {
      n[id] = [
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "\u{2022} point number one of this should be short",
          groupId: id
        ),
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "\u{2022} point number two of this should be short",
          groupId: id
        ),
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "\u{2022} point number three of this should be short",
          groupId: id
        ),
      ]
    }

    return n
  }

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
  case createFailed(String)
}
