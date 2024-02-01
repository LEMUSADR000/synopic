//
//  SynopicSwinjectTests.swift
//  SynopicTests
//
//  Created by adrian.lemus on 1/31/24.
//

import XCTest

@testable import Synopic

final class SynopicSwinjectTests: XCTestCase {
  let appAssembler: AppAssembler = .init()

  func testCoordinatorFactories() {
    let appRoot = appAssembler.resolve(AppRootCoordinator.self)
    XCTAssert(appRoot != nil, "AppRootCoordinator is nil")
    
    let noteRootCoordinator = appAssembler.resolve(NoteCreateCoordinator.self)
    XCTAssert(noteRootCoordinator != nil, "NoteCreateCoordinator is nil")
    
    let noteGroupDetailsCoordinator = appAssembler.resolve(
      NoteGroupDetailsCoordinator.self,
      argument: Group(title: "Title", author: "Author", childCount: 12)
    )
    XCTAssert(noteGroupDetailsCoordinator != nil, "NoteGroupDetailsCoordinator is nil")
  }
  
  func testServiceFactories() {
    let ocrService = appAssembler.resolve(OCRService.self)
    XCTAssert(ocrService != nil, "OCRService is nil")
    
    let persistentStore = appAssembler.resolve(PersistentStore.self)
    XCTAssert(persistentStore != nil, "PersistentStore is nil")
    
    let summariesRepository = appAssembler.resolve(SummariesRepository.self)
    XCTAssert(summariesRepository != nil, "SummariesRepository is nil")
    
    let chatGptService = appAssembler.resolve(ChatGPTService.self)
    XCTAssert(chatGptService != nil, "ChatGPTService is nil")
    
    let cameraManager = appAssembler.resolve(CameraManager.self)
    XCTAssert(cameraManager != nil, "CameraManager is nil")
    
    let cameraService = appAssembler.resolve(CameraService.self)
    XCTAssert(cameraService != nil, "CameraService is nil")
  }
  
  func testViewModelFactories() {
    let landingViewModel = appAssembler.resolve(LandingViewModel.self)
    XCTAssert(landingViewModel != nil, "LandingViewModel is nil")
    
    let noteCreateViewModel = appAssembler.resolve(NoteCreateViewModel.self)
    XCTAssert(noteCreateViewModel != nil, "NoteCreateViewModel is nil")
    
    let notesGridViewModel = appAssembler.resolve(
      NotesGridViewModel.self,
      argument: Group(title: "title", author: "author")
    )
    XCTAssert(notesGridViewModel != nil, "NotesGridViewModel is nil")
    
    let cameraViewModel = appAssembler.resolve(CameraViewModel.self)
    XCTAssert(cameraViewModel != nil, "CameraViewModel is nil")
  }
}
