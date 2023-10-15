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
      // Only store the image name since path may change on re-run
      toUpdate.imageName = group.imageURL?.lastPathComponent
      toUpdate.lastEdited = Date()
<<<<<<< HEAD
=======
      toUpdate.imageName = nil
>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4

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
<<<<<<< HEAD
                created: Date(timeIntervalSince1970: TimeInterval(result.created)))))
=======
                created: Date.init(timeIntervalSince1970: TimeInterval(result.created))
              )))
>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
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
<<<<<<< HEAD

public extension GroupEntityMO {
  override var description: String {
    return
      "title: \(title ?? "")\nauthor: \(author ?? "")\nlastEdited: \(lastEdited?.ISO8601Format() ?? "") imageName: \(imageName ?? "")"
=======
extension GroupEntityMO {
  public override var description: String {
    return
      "title: \(title ?? "")\nauthor: \(author ?? "")\nlastEdited: \(lastEdited?.ISO8601Format() ?? "")"
>>>>>>> c9af2cb4c9ce28eae5109f046cf1da6cdb93b3c4
  }
}
