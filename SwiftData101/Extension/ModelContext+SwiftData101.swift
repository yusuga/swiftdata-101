//
//  ModelContext+SwiftData101.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/25.
//

import Foundation
import SwiftData

public extension ModelContext {
  
  enum StorageType {
    case inMemory
    case file
  }
  
  convenience init(
    for types: any PersistentModel.Type...,
    storageType: StorageType = .inMemory,
    shouldDeleteOldFile: Bool = true,
    fileName: String = #function
  ) throws {
    let schema = Schema(types)
    
    let sqliteURL = URL.documentsDirectory
      .appending(component: fileName)
      .appendingPathExtension("sqlite")
    
    if shouldDeleteOldFile {
      let fileManager = FileManager.default
      
      if fileManager.fileExists(atPath: sqliteURL.path) {
        try fileManager.removeItem(at: sqliteURL)
      }
    }
    
    let modelConfiguration: ModelConfiguration = {
      switch storageType {
      case .inMemory:
        ModelConfiguration(
          schema: schema,
          isStoredInMemoryOnly: true
        )
      case .file:
        ModelConfiguration(
          schema: schema,
          url: sqliteURL
        )
      }
    }()
    
    let modelContainer = try ModelContainer(
      for: schema,
      configurations: [modelConfiguration]
    )
    
    self.init(modelContainer)
  }
  
  func fetch<Model>(
    for type: Model.Type
  ) throws -> [Model] where Model: PersistentModel {
    try fetch(.init())
  }
  
  func fetchCount<Model>(
    for type: Model.Type
  ) throws -> Int where Model: PersistentModel {
    try fetchCount(FetchDescriptor<Model>())
  }
  
  func fetch<Model>(
    for type: Model.Type,
    id persistentModelID: PersistentIdentifier
  ) throws -> Model? where Model: PersistentModel {
    var fetchDescriptor = FetchDescriptor<Model>(
      predicate: #Predicate {
        $0.persistentModelID == persistentModelID
      }
    )
    fetchDescriptor.fetchLimit = 1
    
    return try fetch(fetchDescriptor).first
  }  
  
  func fetch<Model>(
    for type: Model.Type,
    offset: Int? = nil,
    limit: Int? = nil,
    sortBy sortDescriptors: [SortDescriptor<Model>]
  ) throws -> [Model] where Model: PersistentModel {
    var fetchDescriptor = FetchDescriptor<Model>(sortBy: sortDescriptors)
    fetchDescriptor.fetchOffset = offset
    fetchDescriptor.fetchLimit = limit
    
    return try fetch(fetchDescriptor)
  }
}
