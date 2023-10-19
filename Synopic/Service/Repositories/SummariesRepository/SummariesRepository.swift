//
//  SummariesRepository.swift
//  Synopic
//
//  Created by Adrian Lemus on 2/4/23.
//

import Combine
import CombineExt
import CoreData
import Foundation

protocol SummariesRepository {
  func loadGroups() -> AnyPublisher<LazyList<Group>, Error>

  func loadNotes(parent: InternalObjectId) -> AnyPublisher<[Note], Error>

  @discardableResult func updateGroup(group: Group, notes: [Note]) -> AnyPublisher<Group, Error>

  func deleteGroup(group: Group) -> AnyPublisher<Group, Error>

  func requestSummary(text: String, type: SummaryType) -> AnyPublisher<Summary, Error>
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

  func loadGroups() -> AnyPublisher<LazyList<Group>, Error> {
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

      toUpdate.title = group.title
      toUpdate.author = group.author
      toUpdate.theme = group.codableTheme
      toUpdate.lastEdited = Date()

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
  }

  func deleteGroup(group: Group) -> AnyPublisher<Group, Error> {
    return Just(group.id)
      .compactMap { $0 }
      .flatMap { self.persistentStore.delete(for: $0) }
      .map { group }
      .eraseToAnyPublisher()
  }

  // Should this be in ChatGPTService since it doesn't touch data repositories?
  func requestSummary(text: String, type: SummaryType) -> AnyPublisher<Summary, Error> {
    return Future<Summary, Error> { promise in
      Task { [weak self] in
        do {
          let result = try await self!.chatGptApiService.makeRequest(
            content: text, type: type.rawValue)
          guard !result.choices.isEmpty else {
            throw SummariesError.requestFailed("No choices found in result")
          }

          promise(
            .success(
              Summary(
                id: result.id,
                result: result.choices.first?.message.content ?? "#ERROR",
                created: Date(timeIntervalSince1970: TimeInterval(result.created)))))
        } catch {
          promise(.failure(error))
        }
      }
    }.eraseToAnyPublisher()
  }
}

enum SummariesError: Error {
  case dbFailedToCreate(String)
  case requestFailed(String)
  case createFailed(String)
}

// MARK: - Extensions

public extension GroupEntityMO {
  override var description: String {
    "title: \(title ?? "")\nauthor: \(author ?? "")\nlastEdited: \(lastEdited?.ISO8601Format() ?? "") theme: \(theme?.base64EncodedString() ?? "")"
  }
}
