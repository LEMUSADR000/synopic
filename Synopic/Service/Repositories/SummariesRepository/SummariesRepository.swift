//
//  SummariesRepository.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Combine
import CombineExt
import Foundation
import CoreData

enum SummaryType: String {
  case singleSentence = "Summarize the following into a sentence"
  case threePoints = "Summarize the following into three points"
}

protocol SummariesRepository {
  var groups: AnyPublisher<[InternalObjectId: Group], Never> { get }
  var notes: AnyPublisher<[InternalObjectId: [Note]], Never> { get }

  func loadGroups() -> AnyPublisher<[InternalObjectId: Group], Never>
  func loadNotes() -> AnyPublisher<[InternalObjectId: [Note]], Never>

  @discardableResult func createNote(
    parentId: InternalObjectId,
    text: String,
    type: SummaryType
  )
    async throws -> InternalObjectId

  @discardableResult func updateGroup(
    id: InternalObjectId,
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

  nonisolated var notes: AnyPublisher<[InternalObjectId: [Note]], Never> {
    notesCache.publisher
  }

  nonisolated var groups: AnyPublisher<[InternalObjectId: Group], Never> {
    groupsCache.publisher
  }

  func loadGroups() -> AnyPublisher<[InternalObjectId: Group], Never> {
    _ = Future(asyncFunc: {
      try? await self.fetchGroups()
    })

    return self.groupsCache.publisher
  }


  func loadNotes() -> AnyPublisher<[InternalObjectId: [Note]], Never> {
    Task { [unowned self] in
      try? await self.fetchNotes()
    }

    return self.notesCache.publisher
  }

  func updateGroup(id: InternalObjectId, title: String, author: String) async throws
    -> Group?
  {
    guard !title.isEmpty || !author.isEmpty else {
      if await self.notesCache.value[id]?.isEmpty != true {
        await self.groupsCache.removeValue(forKey: id)
        // TODO: Delete from persistent storage
      }
      
      return nil
    }
    
    var group: Group? = await self.groupsCache.value[id] ?? Group(id: id)
    
    group!.title = title
    group!.author = author
    group!.lastEdited = Date()
    
    _ = persistentStore.update { context in
      guard let object: GroupEntityMO = context.registeredObject(for: id) as? GroupEntityMO ?? GroupEntityMO.insertNew(in: context) else {
        throw SummariesError.dbFailedToCreate("No choices found in result")
      }
      object.title = group!.title
      object.author = group!.author
      object.lastEdited = group!.lastEdited
      object.imageName = group!.imageName
      return object
    }
    
    group = await self.groupsCache.setValue(group!, forKey: group!.id)
    
    return group
  }

  func createNote(parentId: InternalObjectId, text: String, type: SummaryType)
    async throws -> InternalObjectId
  {
    return parentId
//    let summary = try await requestSummary(text: text, type: type)
//
//    let parent = await self.groupsCache.getValue(forKey: parentId)
//
//    let note: Note = try! await persistentStore.update { context in
//      let note = Note(context: context)
//      note.created = summary.created
//      note.summary = summary.result
//      note.parent = parent
//
//      return note
//    }.async()
//
//    let notes: [Note]
//    if var notesForId = await self.notesCache.getValue(forKey: parentId) {
//      notesForId.append(note)
//      notes = notesForId
//    }
//    else {
//      notes = [note]
//    }
//
//    await self.notesCache.setValue(notes, forKey: parentId)
//
//    return note.objectID
  }

  // Mark: - Private API

  private let groupsCache = Cache<InternalObjectId, Group>()
  private let notesCache = Cache<InternalObjectId, [Note]>()

  private func fetchGroups() async throws {
    let value = await _loadGroups()
    await self.groupsCache.addAll(value)
  }

  private func _loadGroups() async -> [InternalObjectId: Group] {
    let request = GroupEntityMO.fetchRequest()
    let groups: LazyList<Group> = try! await persistentStore.fetch(request) {
      return Group(from: $0)
    }.async()

    // TODO: Consider returning lazy collection instead of mapping
    let converted = groups.reduce(into: [InternalObjectId: Group]()) { dict, item in
      dict[item.id] = item
    }

    return converted
  }

  private func fetchNotes() async throws {
    let value = await _loadNotes()
    await self.notesCache.addAll(value)
  }

  private func _loadNotes() async -> [InternalObjectId: [Note]] {
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
  case dbFailedToCreate(String)
  case requestFailed(String)
  case createFailed(String)
}

extension Group {
  static func byId(id: InternalObjectId) -> NSFetchRequest<GroupEntityMO> {
    let request = GroupEntityMO.fetchRequest()
    request.predicate = NSPredicate(format: "country.alpha3code == %@", id as CVarArg)
    request.fetchLimit = 1
    return request
  }
}

extension Future where Failure == Error {
    convenience init(asyncFunc: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let result = try await asyncFunc()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
