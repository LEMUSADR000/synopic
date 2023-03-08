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

  func createNote(groupId: String, text: String, type: SummaryType)
    async throws -> String

  // TODO: Should groupId be created at repository level?
  func createGroup(title: String, author: String) async throws -> String
}

class SummariesRepositoryImpl: SummariesRepository {
  // TODO: Associate a loading function which fetches local storage

  private var cancelBag: CancelBag
  private let chatGptApiService: ChatGPTService

  init(chatGptApiService: ChatGPTService) {
    self.chatGptApiService = chatGptApiService
    self.cancelBag = CancelBag()
  }

  nonisolated var notes: AnyPublisher<[String: [Note]], Never> {
    notesSubject.eraseToAnyPublisher()
  }

  nonisolated var groups: AnyPublisher<[String: Group], Never> {
    groupsSubject.eraseToAnyPublisher()
  }

  func loadGroups() -> AnyPublisher<[String: Group], Never> {
    Future<Any?, Error> { promise in
      Task { [unowned self] in
        do {
          try await self.fetchGroups(self.groupsSubject)
          promise(.success(nil))
        }
        catch {
          promise(.failure(error))
        }
      }
    }
    .sink()
    .store(in: &cancelBag)

    return self.groupsSubject.eraseToAnyPublisher()
  }


  func loadNotes() -> AnyPublisher<[String: [Note]], Never> {
    Future<Any?, Error> { promise in
      Task { [unowned self] in
        do {
          try await self.fetchNotes(self.notesSubject)
          promise(.success(nil))
        }
        catch {
          promise(.failure(error))
        }
      }
    }
    .sink()
    .store(in: &cancelBag)

    return self.notesSubject.eraseToAnyPublisher()
  }

  func createGroup(title: String, author: String) async throws -> String {
    let group = Group(
      id: UUID().uuidString,
      created: Date(),
      title: title,
      author: author
    )

    // TODO: Call CoreData & persist create
    await self.groupsCache.setValue(group, forKey: group.id)
    self.groupsSubject.send(await self.groupsCache.value)

    return group.id
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

    if var notesForId = await self.notesCache.getValue(forKey: groupId) {
      notesForId.append(note)
      await self.notesCache.setValue(notesForId, forKey: groupId)
    }
    else {
      await self.notesCache.setValue([note], forKey: groupId)
    }

    self.notesSubject.send(await self.notesCache.value)

    return note.id
  }

  // Mark: - Private API

  private let groupsCache = Cache<String, Group>()
  private let notesCache = Cache<String, [Note]>()

  private lazy var groupsSubject = CurrentValueSubject<[String: Group], Never>(
    [:])
  private lazy var notesSubject = CurrentValueSubject<[String: [Note]], Never>(
    [:])

  private func fetchGroups(
    _ subject: CurrentValueSubject<[String: Group], Never>
  ) async throws {
    let value = await _loadGroups()
    await self.groupsCache.addAll(value)
    subject.send(await self.groupsCache.value)
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

      g[id] = Group(id: id, created: date, title: names[0], author: names[1])
    }

    return g
  }

  private func fetchNotes(
    _ subject: CurrentValueSubject<[String: [Note]], Never>
  ) async throws {
    let value = await _loadNotes()
    await self.notesCache.addAll(value)
    subject.send(await self.notesCache.value)
  }

  private func _loadNotes() async -> [String: [Note]] {
    var n: [String: [Note]] = [:]
    for id in ["0", "1", "2", "3", "4", "5", "6", "7", "8"] {
      n[id] = [
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "note1",
          groupId: id
        ),
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "note2",
          groupId: id
        ),
        Note(
          id: UUID().uuidString,
          created: Date(),
          summary: "note3",
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

extension SummariesRepositoryImpl {
  actor Cache<Key: Hashable, Value> {
    private var dictionary: [Key: Value] = [:]

    func getValue(forKey key: Key) async -> Value? {
      return dictionary[key]
    }

    func setValue(_ value: Value?, forKey key: Key) async {
      dictionary[key] = value
    }

    func addAll(_ dict: [Key: Value]) async {
      for (key, value) in dict {
        dictionary[key] = value
      }
    }

    var value: [Key: Value] {
      get async {
        return dictionary
      }
    }
  }
}
