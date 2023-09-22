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
  case singleSentence = "Summarize the following into the shortest sentence while still capturing most meaning:"
  case threePoints = "Summarize the following into the shortest three points while still capturing most meaning: "
}

protocol SummariesRepository {
  func loadGroups() -> AnyPublisher<LazyList<Group>, Error>
  
  func loadNotes(parent: InternalObjectId) -> AnyPublisher<[Note], Error>
  
  @discardableResult func updateGroup(group: Group, notes: [Note]) -> AnyPublisher<Group, Error>
  
  func deleteGroup(group: Group) -> AnyPublisher<Group, Error>
  
  func requestSummary(text: String, type: SummaryType) async throws
    -> Summary
}

class SummariesRepositoryImpl: SummariesRepository {
  private let chatGptApiService: ChatGPTService
  private let persistentStore: PersistentStore
  private let _groups: CurrentValueSubject<LazyList<Group>, Never>

  init(chatGptApiService: ChatGPTService, persistentStore: PersistentStore) {
    self.chatGptApiService = chatGptApiService
    self.persistentStore = persistentStore
    self._groups = CurrentValueSubject(LazyList.empty)
  }
  
//  var groups: AnyPublisher<LazyList<Group>, Never> { _groups.eraseToAnyPublisher() }

  func loadGroups() -> AnyPublisher<LazyList<Group>, Error> {
    print("SummariesRepository " + Thread.current.description)
    let request = GroupEntityMO.fetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(key: "lastEdited", ascending: true)
    ]
    
    return persistentStore.fetch(request, map: { Group(from: $0) })
  }

  func loadNotes(parent: InternalObjectId) -> AnyPublisher<[Note], Error> {
    let request = NoteEntityMO.fetchRequest()
    request.predicate = NSPredicate(format: "parent = %@", parent)
    
    return persistentStore.fetch(request) {
      Note(from: $0)
    }
    .map {
      var notes = [Note]()
      for note in $0 {
        notes.append(note)
      }
      return notes
    }
    .eraseToAnyPublisher()
  }
  
  func groupForId(id: InternalObjectId) -> AnyPublisher<Group, Error> {
    return persistentStore.fetchObjectById(for: id) {
      Group(from: $0)
    }
    .eraseToAnyPublisher()
  }

  func updateGroup(group: Group, notes: [Note]) -> AnyPublisher<Group, Error> {
    return persistentStore.update { [group, notes] context in
      
      var toUpdate: GroupEntityMO
      if let id = group.id, let cached = try? context.existingObject(with: id) as? GroupEntityMO {
        toUpdate = cached
      } else {
        toUpdate = GroupEntityMO(context: context)
      }
//
//      if notes.isEmpty && group.author.isEmpty && group.title.isEmpty {
//        context.delete(toUpdate)
//
//        if group.id == nil {
//          return nil
//        } else {
//          return group
//        }
//      } else if toUpdate.title == group.title && toUpdate.author == group.author {
//        return nil
//      }
      
      toUpdate.title = group.title
      toUpdate.author = group.author
      toUpdate.lastEdited = Date()
      toUpdate.imageName = nil
      
      for note: Note in notes {
        if note.id == nil {
          let newNote = NoteEntityMO(context: context)
          newNote.created = note.created
          newNote.summary = note.summary
          newNote.parent = toUpdate
          toUpdate.addToChild(newNote)
        }
      }
      
      return Group(from: toUpdate)
    }
    // TODO: Should we move this into the view model layer?
//    .flatMap { [weak self] (updated: Group?) in
//      guard let self = self, updated != nil else {
//        return Just(LazyList<Group>.empty)
//          .setFailureType(to: Error.self)
//          .eraseToAnyPublisher()
//      }
//
//      return self.loadGroups()
//    }
//    .eraseToAnyPublisher()
  }
  
  func deleteGroup(group: Group) -> AnyPublisher<Group, Error> {
    return Just(group.id)
      .compactMap { $0 }
      .flatMap { self.persistentStore.delete(for: $0) }
      .map { group }
      .eraseToAnyPublisher()
  }

  // Should this be in ChatGPTService since it doesn't touch data repositories?
  func requestSummary(text: String, type: SummaryType) async throws
    -> Summary
  {
    // TODO: Explore better (shorter, more accurate, etc) prompts i.e.: `Extreme TLDR`
    let prompt = type.rawValue

    let result = try await chatGptApiService.makeRequest(prompt: "\(prompt) \(text)")
    guard !result.choices.isEmpty else {
      throw SummariesError.requestFailed("No choices found in result")
    }

    return Summary(
      id: result.id,
      result: result.choices.first?.message.content ?? "#ERROR",
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
