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
    XCTAssert(appRoot != nil, "AppRootCoordinator failed to initialize")
    
    let noteRootCoordinator = appAssembler.resolve(NoteCreateCoordinator.self)
    XCTAssert(noteRootCoordinator != nil, "NoteCreateCoordinator failed to initialize")
    
    let noteGroupDetailsCoordinator = appAssembler.resolve(
      NoteGroupDetailsCoordinator.self,
      argument: Group(title: "Title", author: "Author", childCount: 12)
    )
    XCTAssert(noteGroupDetailsCoordinator != nil, "NoteGroupDetailsCoordinator failed to initialize")
  }
  
  func testServiceFactories() {
    let ocrService = appAssembler.resolve(OCRService.self)
    XCTAssert(ocrService != nil, "OCRService failed to initialize")
    
    let persistentStore = appAssembler.resolve(PersistentStore.self)
    XCTAssert(persistentStore != nil, "PersistentStore failed to initialize")
    
    let summariesRepository = appAssembler.resolve(SummariesRepository.self)
    XCTAssert(summariesRepository != nil, "SummariesRepository failed to initialize")
    
    let chatGptService = appAssembler.resolve(ChatGPTService.self)
    XCTAssert(chatGptService != nil, "ChatGPTService failed to initialize")
    
    let cameraManager = appAssembler.resolve(CameraManager.self)
    XCTAssert(cameraManager != nil, "CameraManager failed to initialize")
    
    let cameraService = appAssembler.resolve(CameraService.self)
    XCTAssert(cameraService != nil, "CameraService failed to initialize")
  }
  
  func testViewModelFactories() {
    let landingViewModel = appAssembler.resolve(LandingViewModel.self)
    XCTAssert(landingViewModel != nil, "LandingViewModel failed to initialize")
    
    let noteCreateViewModel = appAssembler.resolve(NoteCreateViewModel.self)
    XCTAssert(noteCreateViewModel != nil, "NoteCreateViewModel failed to initialize")
    
    let notesGridViewModel = appAssembler.resolve(
      NotesGridViewModel.self,
      argument: Group(title: "title", author: "author")
    )
    XCTAssert(notesGridViewModel != nil, "NotesGridViewModel failed to initialize")
    
    let cameraViewModel = appAssembler.resolve(CameraViewModel.self)
    XCTAssert(cameraViewModel != nil, "CameraViewModel failed to initialize")
  }
}
