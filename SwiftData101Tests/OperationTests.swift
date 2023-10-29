//
//  OperationTests.swift
//  SwiftData101Tests
//
//  Created by yusuga on 2023/10/28.
//

import XCTest
import SwiftData
@testable import SwiftData101

final class OperationTests: XCTestCase {
  
  func testInitModelContext() throws {
    let schema = Schema([SimpleItem.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    let modelContainer = try ModelContainer(
      for: SimpleItem.self,
      configurations: modelConfiguration
    )
    let modelContext = ModelContext(modelContainer)
    
    // モデルを初期化
    let item = SimpleItem(value: 1)
    
    // モデルを追加
    modelContext.insert(item)
    try modelContext.save()
    
    // モデルの更新
    item.value = 2
    try modelContext.save()
    
    // モデルの取得
    let fetchDescriptor = FetchDescriptor<SimpleItem>()
    let fetchedItems = try modelContext.fetch(fetchDescriptor)
    
    // モデルの削除
    modelContext.delete(item)
    try modelContext.save()
  }
  
  /// `ModelContext.save()` の挙動を確認
  func testSave() throws {
    let context = try ModelContext(
      for: SimpleItem.self,
      storageType: .file
    )
    context.autosaveEnabled = false // 挙動を明確にするために false に変更
    
    // insert
    context.insert(
      SimpleItem(value: 1)
    )
    
    // save 前だが context にはモデルが1つあることを確認できる
    XCTAssertEqual(
      try context.fetchCount(for: SimpleItem.self),
      1
    )
    
    // ただし、異なる context で fetch すると 0 件になる。
    // これはまだファイルストレージに変更が反映されていなことを意味する。
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      0
    )
    
    // 保存
    try context.save()
    
    // save 後ならファイルストレージに保存されていることを確認できる
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      1
    )
  }
  
  /// `ModelContext.transaction(block:)` の挙動を確認
  func testTransaction() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    context.autosaveEnabled = false // 挙動を明確にするために false に変更
    
    let item = SimpleItem(value: 1)
    try context.transaction {
      context.insert(item)
      
      // トランザクション内だがすでに context にモデルが追加されていることが確認できる
      XCTAssertEqual(
        try context.fetchCount(for: SimpleItem.self),
        1
      )

      // まだファイルストレージに保存されていないことを確認
      XCTAssertEqual(
        try ModelContext(
          for: SimpleItem.self,
          storageType: .file,
          shouldDeleteOldFile: false
        )
        .fetchCount(for: SimpleItem.self),
        0
      )
    }
    
    // モデルが保存されたことを確認できる
    XCTAssertEqual(
      try context.fetchCount(for: SimpleItem.self),
      1
    )
    
    // 異なる context からもモデルがあることを確認できる
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      1
    )
  }
  
  /// `ModelContext.autosaveEnabled == true` の挙動を確認
  func testAutoSave() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    context.autosaveEnabled = true // default も true になっている
    
    context.insert(SimpleItem(value: 1))
    
    XCTAssertEqual(
      try context.fetchCount(for: SimpleItem.self),
      1
    )
    
    // まだファイルストレージに保存されていないことを確認
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      0
    )
    
    let expectation = expectation(description: "Wait for next RunLoop")
    
    // 次の RunLoop を確認
    DispatchQueue.main.async {
      XCTAssertNoThrow(
        {
          // save を読み出すことなく保存されていることが確認できる
          try XCTAssertEqual(
            ModelContext(
              for: SimpleItem.self,
              storageType: .file,
              shouldDeleteOldFile: false
            )
            .fetchCount(for: SimpleItem.self),
            1
          )
        }
      )
      expectation.fulfill()
    }
    
    wait(for: [expectation])
  }
  
  /// `ModelContext.autosaveEnabled == true` の挙動を `RunLoop` で確認
  func testAutoSaveWithRunLoop() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    context.autosaveEnabled = true
    
    context.insert(SimpleItem(value: 1))
    
    XCTAssertEqual(
      try context.fetchCount(for: SimpleItem.self),
      1
    )
    
    // まだファイルストレージに保存されていないことを確認
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      0
    )
    
    let expectation = expectation(description: "Wait for next RunLoop")
    
    XCTAssertEqual(RunLoop.main, RunLoop.current)
    
    RunLoop.main.perform {
      // まだ保存されていない…
      XCTAssertEqual(
        try! ModelContext(
          for: SimpleItem.self,
          storageType: .file,
          shouldDeleteOldFile: false
        )
        .fetchCount(for: SimpleItem.self),
        0
      )
      
      /// 2つ先だと保存されている…
      ///
      /// `DispatchQueue.main` と `RunLoop.main` の違いがあるのかもしれない。
      ///  - SeeAlso: https://www.avanderlee.com/combine/runloop-main-vs-dispatchqueue-main/
      RunLoop.main.perform {
        XCTAssertEqual(
          try! ModelContext(
            for: SimpleItem.self,
            storageType: .file,
            shouldDeleteOldFile: false
          )
          .fetchCount(for: SimpleItem.self),
          1
        )
        
        expectation.fulfill()
      }
    }
    
    waitForExpectations(timeout: 0.1)
  }
  
  /// `ModelContext.autosaveEnabled == true` の挙動を `MainActor` で確認
  func testAutoSaveWithMainActor() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    
    context.insert(SimpleItem(value: 1))
    
    XCTAssertEqual(
      try context.fetchCount(for: SimpleItem.self),
      1
    )
    
    // まだファイルストレージに保存されていないことを確認
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      0
    )
      
    let expectation = expectation(description: "Wait for next RunLoop")

    Task {
      try await MainActor.run {
        // 保存されていることが確認できる
        XCTAssertEqual(
          try ModelContext(
            for: SimpleItem.self,
            storageType: .file,
            shouldDeleteOldFile: false
          )
          .fetchCount(for: SimpleItem.self),
          1
        )
        
        expectation.fulfill()
      }
    }

    waitForExpectations(timeout: 0.1)
  }
  
  /// `ModelContext.autosaveEnabled == true` で `MainActor` 内で保存した時の挙動を確認
  func testAutoSaveAfterUpdateInMainActor() async throws {
    let expectation = expectation(description: "Wait for next RunLoop")

    Task {
      try await MainActor.run {
        let context = try ModelContext(for: SimpleItem.self, storageType: .file)
        
        context.insert(SimpleItem(value: 1))
        
        XCTAssertEqual(
          try context.fetchCount(for: SimpleItem.self),
          1
        )
        
        // まだファイルストレージに保存されていないことを確認
        XCTAssertEqual(
          try ModelContext(
            for: SimpleItem.self,
            storageType: .file,
            shouldDeleteOldFile: false
          )
          .fetchCount(for: SimpleItem.self),
          0
        )
        
        expectation.fulfill()
      }
    }
    
    await fulfillment(of: [expectation])
    
    // 保存されていることが確認できる
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      1
    )
  }
  
  // バックグラウンドでの保存を確認
  func testSaveInBackground() async throws {
    // test メソッドは async をつけるとバックグラウンドスレッドで実行される
    XCTAssertFalse(Thread.isMainThread)
    
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    context.autosaveEnabled = false
    
    let item = SimpleItem(value: 1)
    context.insert(item)
    
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 1)
    
    try await MainActor.run {
      // まだファイルストレージに保存されていないことを確認
      XCTAssertEqual(
        try ModelContext(
          for: SimpleItem.self,
          storageType: .file,
          shouldDeleteOldFile: false
        )
        .fetchCount(for: SimpleItem.self),
        0
      )
    }
    
    try context.save()
    
    // save 後にファイルストレージに保存されていることが確認できる
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      1
    )
    
    try await MainActor.run {
      // メインスレッドからも確認できる
      XCTAssertEqual(
        try ModelContext(
          for: SimpleItem.self,
          storageType: .file,
          shouldDeleteOldFile: false
        )
        .fetchCount(for: SimpleItem.self),
        1
      )
    }
  }
  
  /// バックグラウンドでの `autoSave` の挙動を確認
  func testAutoSaveInBackground() async throws {
    XCTAssertFalse(Thread.isMainThread)
    
    let expectation = expectation(description: "Wait for task to complete")
    
    Task.detached {
      XCTAssertFalse(Thread.isMainThread)
      
      let context = try ModelContext(for: SimpleItem.self, storageType: .file)
      
      let item = SimpleItem(value: 1)
      context.insert(item)
      
      XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 1)
      
      // まだファイルストレージに保存されていないことを確認
      XCTAssertEqual(
        try ModelContext(
          for: SimpleItem.self,
          storageType: .file,
          shouldDeleteOldFile: false
        )
        .fetchCount(for: SimpleItem.self),
        0
      )
      
      // 次の RunLoop でも保存されていない
      try await MainActor.run {
        let otherContext = try ModelContext(
          for: SimpleItem.self,
          storageType: .file,
          shouldDeleteOldFile: false
        )
        
        XCTAssertEqual(
          try otherContext.fetchCount(for: SimpleItem.self),
          0
        )
      }
      
      expectation.fulfill()
    }
    
    await fulfillment(of: [expectation])
    
    // Task が終わった後もファイルストレージに保存されていない
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetchCount(for: SimpleItem.self),
      0
    )
    
    // メインスレッドでも更新されていない
    try await MainActor.run {
      XCTAssertEqual(
        try ModelContext(
          for: SimpleItem.self,
          storageType: .file,
          shouldDeleteOldFile: false
        )
        .fetchCount(for: SimpleItem.self),
        0
      )
    }
  }
  
  // model の insert と update を確認
  func testInsertAndUpdate() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    
    let item = SimpleItem(value: 1)
    context.insert(item)
    
    XCTAssertTrue(context.hasChanges)
    XCTAssertFalse(context.insertedModelsArray.isEmpty)
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 1)
    XCTAssertEqual(try context.fetch(for: SimpleItem.self).first?.value, 1)
    
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 1)
    XCTAssertEqual(try context.fetch(for: SimpleItem.self).first?.value, 1)
    
    XCTAssertFalse(context.hasChanges)
    XCTAssertTrue(context.changedModelsArray.isEmpty)
    
    // 特にトランザクションなど不要で値の変更が可能
    item.value = 2
    
    // context から fetch した値も save する前に更新されている
    XCTAssertEqual(try XCTUnwrap(context.fetch(for: SimpleItem.self).first).value, 2)
    // context に変更フラグが立っている
    XCTAssertTrue(context.hasChanges)
    // 変更されたモデルのリストも更新されている
    XCTAssertEqual(context.changedModelsArray.count, 1)
        
    // ファイルストレージの値はまだ更新されていない
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetch(for: SimpleItem.self).first?.value,
      1
    )
    
    try context.save()
    
    // save 後にファイルストレージの値が更新されていることを確認できる
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetch(for: SimpleItem.self).first?.value,
      2
    )
  }
  
  func testDelete() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    
    let item = SimpleItem(value: 1)
    context.insert(item)
    try context.save()
    
    context.delete(item)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 0)
    XCTAssertTrue(try context.fetch(for: SimpleItem.self).isEmpty)
    
    // すでに削除された item を削除しようとしてもエラーはスローされない
    context.delete(item)
    try context.save()
    
    // 異なる context で存在しない item を削除しようとしてもエラーはスローされない
    let otherContext = try ModelContext(for: SimpleItem.self, storageType: .file, shouldDeleteOldFile: false)
    otherContext.delete(SimpleItem(value: 1))
    try otherContext.save()
  }
  
  func testDeleteWithPredicate() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    
    let item1 = SimpleItem(value: 1)
    let item2 = SimpleItem(value: 2)
    context.insert(item1)
    context.insert(item2)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 2)
    
    try context.delete(
      model: SimpleItem.self,
      where: #Predicate {
        $0.value == 1
      }
    )
    
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 1)
    XCTAssertEqual(try context.fetch(for: SimpleItem.self).first?.value, 2)
    XCTAssertEqual(
      try ModelContext(
        for: SimpleItem.self,
        storageType: .file,
        shouldDeleteOldFile: false
      )
      .fetch(for: SimpleItem.self).first?.value,
      2
    )
  }
  
  func testDeleteWithIncludeSubclasses() throws {
    let context = try ModelContext(for: ExplicitOneToOneItem.self)

    let child = ChildExplicitOneToOneItem(id: 10)
    let parent = ExplicitOneToOneItem(id: 1, child: child)
    
    context.insert(parent)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: ExplicitOneToOneItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitOneToOneItem.self), 1)
  }
  
  /// すべてのモデルを fetch する
  func testFetchAll() throws {
    let context = try ModelContext(for: SimpleItem.self)
    
    let count: Int = 10
    
    // モデルを 10 個 insert する
    (0..<count).forEach {
      context.insert(
        SimpleItem(value: $0)
      )
    }
    try context.save()

    // FetchDescriptor で predicate を省略すると全件取得になる
    let fetchDescriptor = FetchDescriptor<SimpleItem>()
    
    XCTAssertEqual(
      try context.fetch(fetchDescriptor).count,
      count
    )
    XCTAssertEqual(
      try context.fetchCount(fetchDescriptor),
      count
    )
    
    // `public static var `true`: Predicate<repeat each Input> { get }` も用意されている
    XCTAssertEqual(
      try context.fetch(
        FetchDescriptor<SimpleItem>(
          predicate: Predicate.true
        )
      )
      .count,
      count
    )
    
    // 条件を指定して fetch
    XCTAssertEqual(
      try context.fetch(
        FetchDescriptor<SimpleItem>(
          predicate: #Predicate {
            $0.value == 5
          }
        )
      )
      .first?.value,
      5
    )
    
    // 便利メソッドの動作確認
    XCTAssertEqual(
      try context.fetch(for: SimpleItem.self).count,
      count
    )
    XCTAssertEqual(
      try context.fetchCount(for: SimpleItem.self),
      count
    )
  }
  
  /// `PersistentModel.persistentModelID` を使って `fetch`
  func testFetchForPersistentModelID() throws {
    let context = try ModelContext(for: SimpleItem.self)
    
    let item = SimpleItem(value: 1)
    
    context.insert(item)
    try context.save()
    
    let persistentModelID = item.persistentModelID
    
    var fetchDescriptor = FetchDescriptor<SimpleItem>(
      predicate: #Predicate {
        $0.persistentModelID == persistentModelID
      }
    )
    // limit は必須ではないけどつけたら短絡評価になることを期待
    fetchDescriptor.fetchLimit = 1
    
    XCTAssertNotNil(
      try context.fetch(fetchDescriptor).first
    )
    XCTAssertEqual(
      try context.fetchCount(fetchDescriptor),
      1
    )
    
    /// `PersistentModel` は `Identifiable` に準拠しているので  `id` を持っている。
    /// デフォルト実装が `public var id: PersistentIdentifier { get }` となっているため以下が成立する。
    XCTAssertEqual(
      item.persistentModelID,
      item.id
    )
    
    /// 便利メソッドの動作確認
    XCTAssertNotNil(
      try context.fetch(for: SimpleItem.self, id: item.persistentModelID)
    )
    XCTAssertNotNil(
      try context.fetch(for: SimpleItem.self, id: item.id)
    )

    /// `#Predicate` にはオブジェクトを直接渡して指定できないケースがある。
    /// 例えば以下は
    /// `Cannot convert value of type 'PredicateExpressions.Equal<PredicateExpressions.KeyPath<PredicateExpressions.Variable<SimpleItem>, PersistentIdentifier>, PredicateExpressions.KeyPath<PredicateExpressions.Value<SimpleItem>, PersistentIdentifier>>' to closure result type 'any StandardPredicateExpression<Bool>'`
    /// というビルドエラーが発生してしまう。
    /// これは `#Predicate` マクロが KeyPath を生成するときに
    /// `PredicateExpressions.Variable<SimpleItem>` と `KeyPath<PredicateExpressions.Value<SimpleItem>`
    /// のように異なる型を比較してしまうため。
    /*
    let fetchDescriptor = FetchDescriptor<SimpleItem>(
      predicate: #Predicate {
        $0.persistentModelID == item.persistentModelID
      }
    )
     */
  }
  
  /// カスタムした `id` で `fetch`
  func testFetchForCustomID() throws {
    let context = try ModelContext(for: CustomIDItem.self)
    
    let id = 1
    let item = CustomIDItem(id: id)
    
    context.insert(item)
    try context.save()
        
    XCTAssertNotNil(
      try context.fetch(
        FetchDescriptor<CustomIDItem>(
          predicate: #Predicate {
            $0.id == id
          }
        )
      )
      .first
    )
    
    /// persistentModelID でも問題なく fetch できる
    XCTAssertNotNil(
      try context.fetch(
        for: CustomIDItem.self,
        id: item.persistentModelID
      )
    )
  }
  
  /// ページネーションを確認
  func testFetchWithPagination() throws {
    let context = try ModelContext(for: UniqueItem.self)
    
    // 100 件モデルを追加
    (0..<100).forEach {
      let newItem = UniqueItem(id: $0, value: $0.description)
      context.insert(newItem)
    }
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: UniqueItem.self), 100)
    
    // sort を指定しないと順不同で値が返ってきてしまう
    let sort = SortDescriptor(\UniqueItem.id)
    
    do {
      // id が 0 〜 9 のモデルを取得
      var fetchDescriptor = FetchDescriptor<UniqueItem>(sortBy: [sort])
      fetchDescriptor.fetchOffset = 0
      fetchDescriptor.fetchLimit = 10
      
      XCTAssertEqual(
        try context.fetch(fetchDescriptor).map { $0.id },
        Array(0..<10)
      )
    }
    
    do {
      // id が 10 〜 19 のモデルを取得
      var fetchDescriptor = FetchDescriptor<UniqueItem>(sortBy: [sort])
      fetchDescriptor.fetchOffset = 10
      fetchDescriptor.fetchLimit = 10
      
      XCTAssertEqual(
        try context.fetch(fetchDescriptor).map { $0.id },
        Array(10..<20)
      )
    }
    
    /// 便利メソッドの動作確認
    XCTAssertEqual(
      try context.fetch(for: UniqueItem.self, offset: 0, limit: 10, sortBy: [sort])
        .map { $0.id },
      Array(0..<10)
    )
    XCTAssertEqual(
      try context.fetch(for: UniqueItem.self, offset: 10, limit: 10, sortBy: [sort])
        .map { $0.id },
      Array(10..<20)
    )
  }
  
  func testFetchCount() throws {
    let context = try ModelContext(for: SimpleItem.self)
    let count = 100
    
    (0..<count).forEach {
      let newItem = SimpleItem(value: $0)
      context.insert(newItem)
    }
    try context.save()
    
    // 条件を指定
    let fetchDescriptor = FetchDescriptor<SimpleItem>()

    XCTAssertEqual(
      try context.fetchCount(fetchDescriptor),
      count
    )
  }
  
  /// 調査中。動作させる方法がわからない
  func testRollback() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)
    
    let item = SimpleItem(value: 1)
    context.insert(item)
    
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 1)
    XCTAssertEqual(try XCTUnwrap(context.fetch(for: SimpleItem.self).first).value, 1)
    
    XCTAssertTrue(context.hasChanges)
    XCTAssertFalse(context.insertedModelsArray.isEmpty)
    
    context.rollback()
    
    XCTAssertFalse(context.hasChanges)
    XCTAssertTrue(context.insertedModelsArray.isEmpty)
    
    // insert のロールバックができていない…
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 1)
    
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: SimpleItem.self), 1)
    
    item.value = 2
    
    // save の前に更新されている
    XCTAssertEqual(try XCTUnwrap(context.fetch(for: SimpleItem.self).first).value, 2)
    
    context.rollback()
    
    XCTAssertEqual(item.value, 2)
    
    // update のロールバックもできない…
    XCTAssertEqual(try XCTUnwrap(context.fetch(for: SimpleItem.self).first).value, 2)
  }
}
