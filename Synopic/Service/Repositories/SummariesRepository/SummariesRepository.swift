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
  var groups: AnyPublisher<LazyList<Group>, Never> { get }
  
  func loadGroups()
  
  func loadNotes(parent: InternalObjectId) -> AnyPublisher<[Note], Error>
  
  @discardableResult func updateGroup(group: Group, notes: [Note]) async throws -> Group?
  
  func requestSummary(text: String, type: SummaryType) async throws
    -> SummaryResponse
}

class SummariesRepositoryImpl: SummariesRepository {
  private let chatGptApiService: ChatGPTService
  private let persistentStore: PersistentStore
  private let _groups: CurrentValueSubject<LazyList<Group>, Never>
  private var cancelBag = CancelBag()

  init(chatGptApiService: ChatGPTService, persistentStore: PersistentStore) {
    self.chatGptApiService = chatGptApiService
    self.persistentStore = persistentStore
    self._groups = CurrentValueSubject(LazyList.empty)
  }
  
  var groups: AnyPublisher<LazyList<Group>, Never> { _groups.eraseToAnyPublisher() }

  func loadGroups() {
    let request = GroupEntityMO.fetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(key: "lastEdited", ascending: true)
    ]
    
    persistentStore.fetch(request) {
      Group(from: $0)
    }.sink(receiveValue: { [weak self] result in
      guard let self = self else { return }
      self._groups.send(result)
    }).store(in: &cancelBag)
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

  func updateGroup(group: Group, notes: [Note]) async throws -> Group? {
    let new: Group? = try? await persistentStore.update { [group, notes] context in
      var toUpdate: GroupEntityMO
      if let id = group.id, let cached = try? context.existingObject(with: id) as? GroupEntityMO {
        toUpdate = cached
      } else {
        toUpdate = GroupEntityMO(context: context)
      }
  
      if notes.count == 0 && group.author.isEmpty && group.title.isEmpty {
        context.delete(toUpdate)
        return nil
      }
      
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
      
      // TODO: Figure out how to remove items that are no longer part of current children in set

      return Group(from: toUpdate)
    }.async()
    
    if new != nil {
      loadGroups()
    }
    
    return new
  }

  func requestSummary(text: String, type: SummaryType) async throws
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


