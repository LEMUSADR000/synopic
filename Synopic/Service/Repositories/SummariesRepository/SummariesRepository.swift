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
  var groups: AnyPublisher<[ObjectIdentifier: Group], Never> { get }
  var notes: AnyPublisher<[ObjectIdentifier: [Note]], Never> { get }

  func loadGroups() -> AnyPublisher<[ObjectIdentifier: Group], Never>
  func loadNotes() -> AnyPublisher<[ObjectIdentifier: [Note]], Never>

  @discardableResult func createNote(
    parentId: ObjectIdentifier,
    text: String,
    type: SummaryType
  )
    async throws -> ObjectIdentifier

  @discardableResult func updateGroup(
    id: ObjectIdentifier,
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

  nonisolated var notes: AnyPublisher<[ObjectIdentifier: [Note]], Never> {
    notesCache.publisher
  }

  nonisolated var groups: AnyPublisher<[ObjectIdentifier: Group], Never> {
    groupsCache.publisher
  }

  func loadGroups() -> AnyPublisher<[ObjectIdentifier: Group], Never> {
    Task { [unowned self] in
      try? await self.fetchGroups()
    }

    return self.groupsCache.publisher
  }


  func loadNotes() -> AnyPublisher<[ObjectIdentifier: [Note]], Never> {
    Task { [unowned self] in
      try? await self.fetchNotes()
    }

    return self.notesCache.publisher
  }

  func updateGroup(id: ObjectIdentifier, title: String, author: String) async throws
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
      group = try! await persistentStore.update { context in
        return Group(context: context)
      }.async()
    }
        
    let updated: Group = try! await persistentStore.update { context in
      group!.title = title
      group!.author = title
      group!.lastEdited = Date()
      return group!
    }.async()
    
    group = await self.groupsCache.setValue(updated, forKey: updated.id)
    
    return group
  }

  func createNote(parentId: ObjectIdentifier, text: String, type: SummaryType)
    async throws -> ObjectIdentifier
  {
    let summary = try await requestSummary(text: text, type: type)
    
    let parent = await self.groupsCache.getValue(forKey: parentId)
    
    let note: Note = try! await persistentStore.update { context in
      let note = Note(context: context)
      note.created = summary.created
      note.summary = summary.result
      note.parent = parent
      
      return note
    }.async()

    let notes: [Note]
    if var notesForId = await self.notesCache.getValue(forKey: parentId) {
      notesForId.append(note)
      notes = notesForId
    }
    else {
      notes = [note]
    }

    await self.notesCache.setValue(notes, forKey: parentId)

    return note.id
  }

  // Mark: - Private API

  private let groupsCache = Cache<ObjectIdentifier, Group>()
  private let notesCache = Cache<ObjectIdentifier, [Note]>()

  private func fetchGroups() async throws {
    let value = await _loadGroups()
    await self.groupsCache.addAll(value)
  }

  private func _loadGroups() async -> [ObjectIdentifier: Group] {
    try? await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second

//    let today = Date()
//    let gIds = [
//      ["Lion's King", "James"],
//      ["Enders Game", "Bernard"],
//      ["Star Wars", "Xander"],
//      ["Lion's Witch", "Gertrude"],
//      ["One Piece", "Clint"],
//      ["Ronaldo", "Ronaldo"],
//      ["Clintonail Pt 2", "Clint"],
//      ["Randall's Wine", "Dwinles"],
//      ["Great Reservation", "Chines"],
//    ]
//
//    var g: [String: Group] = [:]
//    for (index, names) in gIds.enumerated() {
//      let id = "\(index)"
//
//      let date = today.adding(days: -index)
//
//      g[id] = Group(
//        id: id,
//        lastEdited: date,
//        title: names[0],
//        author: names[1]
//      )
//    }

    return [:]
  }

  private func fetchNotes() async throws {
    let value = await _loadNotes()
    await self.notesCache.addAll(value)
  }

  private func _loadNotes() async -> [ObjectIdentifier: [Note]] {
//    var n: [String: [Note]] = [:]
//    for id in ["0", "1", "2", "3", "4", "5", "6", "7", "8"] {
//      n[id] = [
//        Note(
//          id: UUID().uuidString,
//          created: Date(),
//          summary: "\u{2022} point number one of this should be short",
//          groupId: id
//        ),
//        Note(
//          id: UUID().uuidString,
//          created: Date(),
//          summary: "\u{2022} point number two of this should be short",
//          groupId: id
//        ),
//        Note(
//          id: UUID().uuidString,
//          created: Date(),
//          summary: "\u{2022} point number three of this should be short",
//          groupId: id
//        ),
//      ]
//    }

    return [:]
  }

  private func requestSummary(text: String, type: SummaryType) async throws
    -> SummaryResponse
  {
    // TODO: Explore better (shorter, more accurate, etc) prompts i.e.: `Extreme TLDR`
    let prompt = type.rawValue

    let result = try await chatGptApiService.makeRequest(prompt: prompt)
    guard !result.choices.isEmpty else {
      throw SummariesError.requestFailed("No choices found in result")
    }

    return SummaryResponse(
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
