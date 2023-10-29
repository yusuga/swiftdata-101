//
//  AttributeTests.swift
//  SwiftData101Tests
//
//  Created by yusuga on 2023/10/27.
//

import XCTest
import SwiftData
@testable import SwiftData101

final class AttributeTests: XCTestCase {
  
  func testUnique() throws {
    let context = try ModelContext(for: UniqueItem.self)
          
    do {
      let newItem = UniqueItem(id: 1, value: "a")
      context.insert(newItem)
      try context.save()
      
      XCTAssertEqual(
        try context.fetchCount(for: UniqueItem.self), 1
      )
      XCTAssertEqual(
        try context.fetch(for: UniqueItem.self).first?.value,
        newItem.value
      )
      
      // 同一 id で value が異なるモデルを insert する
      let updatedItem = UniqueItem(id: newItem.id, value: "b")
      context.insert(updatedItem)
      
      // 保存前の context には一時的に2つのオブジェクトが含まれていて fetch も可能
      let items = try context.fetch(
        for: UniqueItem.self,
        sortBy: [.init(\UniqueItem.value)]
      )
      XCTAssertEqual(items.count, 2)
      XCTAssertEqual(items[0].value, newItem.value)
      XCTAssertEqual(items[1].value, updatedItem.value)
      
      // insertedModelsArray には updatedItem が含まれている
      XCTAssertEqual(context.insertedModelsArray.count, 1)
      XCTAssertEqual(
        (context.insertedModelsArray[0] as? UniqueItem)?.value,
        updatedItem.value
      )
    }
    
    try context.save()
    
    do {
      // 保存後はモデルは1つになり、 value も更新されている
      let items = try context.fetch(for: UniqueItem.self)
      XCTAssertEqual(items.count, 1)
      XCTAssertEqual(items.first?.value, "b")
      XCTAssertTrue(context.insertedModelsArray.isEmpty)
    }
  }
  
  func testTransient() throws {
    let context = try ModelContext(for: TransientItem.self, storageType: .file)
        
    let item = TransientItem(value: 1)
    let defaultValue = item.ignoreValue
    let updatedValue = 100
    XCTAssertNotEqual(defaultValue, updatedValue)
    
    item.ignoreValue = updatedValue
    context.insert(item)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: TransientItem.self), 1)
    
    // 保存後も更新した値になっていることを確認
    XCTAssertEqual(item.ignoreValue, updatedValue)
    
    // 同一 context から fetch したモデルは updatedValue になっていることに注意
    XCTAssertEqual(
      try context.fetch(for: TransientItem.self).first?.ignoreValue,
      updatedValue
    )
    
    // 異なる context から fetch したモデルは defaultValue になっている
    XCTAssertEqual(
      try ModelContext(
        for: TransientItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetch(for: TransientItem.self).first?.ignoreValue,
      defaultValue
    )
  }
}
