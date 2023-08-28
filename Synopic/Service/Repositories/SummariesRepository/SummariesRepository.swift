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
  func groupForId(id: InternalObjectId) -> AnyPublisher<Group?, Never>
  func loadGroups() -> AnyPublisher<LazyList<Group>, Error>
  func loadNotes(parent: InternalObjectId) -> AnyPublisher<LazyList<Note>, Error>

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
  private let chatGptApiService: ChatGPTService
  private let persistentStore: PersistentStore

  init(chatGptApiService: ChatGPTService, persistentStore: PersistentStore) {
    self.chatGptApiService = chatGptApiService
    self.persistentStore = persistentStore
  }

  func loadGroups() -> AnyPublisher<LazyList<Group>, Error> {
    let request = GroupEntityMO.fetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(key: "lastEdited", ascending: true)
    ]
    return persistentStore.fetch(request) {
      Group(from: $0)
    }.eraseToAnyPublisher()
  }

  func loadNotes(parent: InternalObjectId) -> AnyPublisher<LazyList<Note>, Error> {
    let request = NoteEntityMO.fetchRequest()
    request.predicate = NSPredicate(format: "parent = %@", parent)
    
    return persistentStore.fetch(request) {
      Note(from: $0)
    }.eraseToAnyPublisher()
  }
  
  func groupForId(id: InternalObjectId) -> AnyPublisher<Group?, Never> {
    return persistentStore.fetchObjectById(for: id) {
      Group(from: $0)
    }
    .replaceError(with: nil)
    .eraseToAnyPublisher()
  }

  func updateGroup(id: InternalObjectId, title: String, author: String) async throws
    -> Group?
  {
    if (title.isEmpty && author.isEmpty), let entity: GroupEntityMO = try? await persistentStore.fetchObjectById(for: id, map: { $0 as GroupEntityMO }).async(), entity.child?.count == 0 {
      persistentStore.delete(object: entity)
      return nil
    }
    
    let entity: GroupEntityMO? = try? await persistentStore.fetchObjectById(for: id, map: { $0 as GroupEntityMO? }).async()
    return try? await persistentStore.update { context in
      let object = entity ?? GroupEntityMO(context: context)
      object.title = title
      object.author = author
      object.lastEdited = Date()
      object.imageName = nil
      
      return Group(from: object)
    }.async()
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

// MARK: - Extensions
extension GroupEntityMO {
  public override var description : String {
    return "title: \(title ?? "")\nauthor: \(author ?? "")\nlastEdited: \(lastEdited?.ISO8601Format() ?? "")"
  }
}

// MARK: - Fetch Requests


