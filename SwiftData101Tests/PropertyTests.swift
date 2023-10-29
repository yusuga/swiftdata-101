//
//  PropertyTests.swift
//  SwiftData101Tests
//
//  Created by yusuga on 2023/10/27.
//

import XCTest
import SwiftData
@testable import SwiftData101

final class PropertyTests: XCTestCase {
  
  func testVariousTypesItem() throws {
    let context = try ModelContext(
      for: VariousTypesItem.self
    )
    
    let uuid = UUID()
    let date = Date()
    let newItem = VariousTypesItem(
      string: "a",
      int: .max,
      double: .greatestFiniteMagnitude,
      decimal: .init(UInt.max),
      bool: true,
      date: date,
      data: "A".data(using: .utf8)!,
      uuid: uuid,
      strings: ["1", "2", "3"],
      ints: [1, 2, 3]
    )
    
    context.insert(newItem)
    try context.save()
    
    try XCTAssertEqual(
      context.fetchCount(for: VariousTypesItem.self),
      1
    )
    
    let fetchedItem = try XCTUnwrap(
      context.fetch(for: VariousTypesItem.self).first
    )
    XCTAssertEqual(fetchedItem.string, "a")
    XCTAssertEqual(fetchedItem.int, .max)
    XCTAssertEqual(fetchedItem.double, .greatestFiniteMagnitude)
    XCTAssertEqual(fetchedItem.decimal, .init(UInt.max))
    XCTAssertEqual(fetchedItem.bool, true)
    XCTAssertEqual(fetchedItem.date, date)
    XCTAssertEqual(fetchedItem.data, "A".data(using: .utf8)!)
    XCTAssertEqual(fetchedItem.uuid, uuid)
    XCTAssertEqual(fetchedItem.strings, ["1", "2", "3"])
    XCTAssertEqual(fetchedItem.ints, [1, 2, 3])
  }
  
  func testOptionalItemWithValue() throws {
    let context = try ModelContext(for: OptionalItem.self)
    
    let uuid = UUID()
    let date = Date()
    let newItem = OptionalItem(
      string: "a",
      int: .max,
      double: .greatestFiniteMagnitude,
      decimal: .init(UInt.max),
      bool: true,
      date: date,
      data: "A".data(using: .utf8)!,
      uuid: uuid,
      strings: ["1", "2", "3"],
      ints: [1, 2, 3],
      optionalStrings: ["1", "2", "3"],
      optionalInts: [1, 2, 3]
    )
    context.insert(newItem)
    try context.save()
    
    try XCTAssertEqual(context.fetchCount(for: OptionalItem.self), 1)
    
    let fetchedItem = try XCTUnwrap(context.fetch(for: OptionalItem.self).first)
    XCTAssertEqual(fetchedItem.string, "a")
    XCTAssertEqual(fetchedItem.int, .max)
    XCTAssertEqual(fetchedItem.double, .greatestFiniteMagnitude)
    XCTAssertEqual(fetchedItem.decimal, .init(UInt.max))
    XCTAssertEqual(fetchedItem.bool, true)
    XCTAssertEqual(fetchedItem.date, date)
    XCTAssertEqual(fetchedItem.data, "A".data(using: .utf8)!)
    XCTAssertEqual(fetchedItem.uuid, uuid)
    XCTAssertEqual(fetchedItem.strings, ["1", "2", "3"])
    XCTAssertEqual(fetchedItem.ints, [1, 2, 3])
    XCTAssertEqual(fetchedItem.optionalStrings, ["1", "2", "3"])
    XCTAssertEqual(fetchedItem.optionalInts, [1, 2, 3])
  }
  
  func testOptionalItemWithNil() throws {
    let context = try ModelContext(for: OptionalItem.self)
    
    let newItem = OptionalItem(
      optionalStrings: [nil],
      optionalInts: [nil]
    )
    context.insert(newItem)
    try context.save()
    
    try XCTAssertEqual(context.fetchCount(for: OptionalItem.self), 1)
    
    let fetchedItem = try XCTUnwrap(
      context.fetch(for: OptionalItem.self).first
    )
    XCTAssertNil(fetchedItem.string)
    XCTAssertNil(fetchedItem.int)
    XCTAssertNil(fetchedItem.double)
    XCTAssertNil(fetchedItem.decimal)
    XCTAssertNil(fetchedItem.bool)
    XCTAssertNil(fetchedItem.date)
    XCTAssertNil(fetchedItem.data)
    XCTAssertNil(fetchedItem.uuid)
    XCTAssertNil(fetchedItem.strings)
    XCTAssertNil(fetchedItem.ints)
    XCTAssertEqual(fetchedItem.optionalStrings, [nil])
    XCTAssertEqual(fetchedItem.optionalInts, [nil])
  }
  
  func testNestedStructItem() throws {
    let context = try ModelContext(
      for: CodableStructItem.self
    )
    
    let date = Date()
    let uuid = UUID()
    let newItem = CodableStructItem(
      child: .init(
        string: "a",
        int: .max,
        double: .greatestFiniteMagnitude,
        decimal: .init(UInt.max),
        bool: true,
        date: date,
        data: "A".data(using: .utf8)!,
        uuid: uuid,
        plainEnum: .foo,
        grandchild: .init(value: 1)
      )
    )
    
    context.insert(newItem)
    try context.save()
    
    let fetchedItem = try XCTUnwrap(
      context.fetch(for: CodableStructItem.self).first
    )
    XCTAssertEqual(fetchedItem.child.string, "a")
    XCTAssertEqual(fetchedItem.child.int, .max)
    XCTAssertEqual(fetchedItem.child.double, .greatestFiniteMagnitude)
    XCTAssertEqual(fetchedItem.child.decimal, .init(UInt.max))
    XCTAssertEqual(fetchedItem.child.bool, true)
    XCTAssertEqual(fetchedItem.child.date, date)
    XCTAssertEqual(fetchedItem.child.data, "A".data(using: .utf8)!)
    XCTAssertEqual(fetchedItem.child.uuid, uuid)
    XCTAssertEqual(fetchedItem.child.plainEnum, .foo)
    XCTAssertEqual(fetchedItem.child.grandchild.value, 1)
  }
  
  func testInvalidCodableStructItemHasOptionalInt() throws {
    let type = InvalidCodableStructItemHasOptionalInt.self
    
    let context = try ModelContext(for: type, storageType: .file)
    
    let item = type.init(
      child: .init(optionalValue: nil)
    )
    
    context.insert(item)
    try context.save()
    
    // プロパティにはアクセスできる
    XCTAssertNil(item.child.optionalValue)
    // count では存在している
    XCTAssertEqual(try context.fetchCount(for: type), 1)
    // fetch できる
    XCTAssertNotNil(try context.fetch(for: type).first)
    // 異なる context からも fetch できる
    XCTAssertNotNil(
      try ModelContext(for: type, storageType: .file, shouldDeleteOldFile: false)
        .fetch(for: type)
        .first
    )
  }
  
  func testInvalidCodableStructItemHasOptionalString() throws {
    let type = InvalidCodableStructItemHasOptionalString.self
    
    let context = try ModelContext(for: type)
    
    let item = type.init(
      child: .init(optionalValue: nil)
    )
    
    context.insert(item)
    try context.save()
    
    // プロパティにはアクセスできる
    XCTAssertNil(item.child.optionalValue)
    
    // count では存在している
    XCTAssertEqual(try context.fetchCount(for: type), 1)
    
    /// 以下のログが出力されてモデルが取得できない
    ///
    /// ```
    /// CoreData: error: Row (pk = 1) for entity 'InvalidCodableStructItemHasOptional' is missing mandatory text data for property 'optionalString'
    /// ```
    XCTAssertNil(
      try context.fetch(for: type).first
    )
    
    // 異なる context には存在しない。つまりファイルストレージに保存されていないと言える。
    XCTAssertEqual(
      try ModelContext(for: type, storageType: .file, shouldDeleteOldFile: false)
        .fetchCount(for: type),
      0
    )
    XCTAssertNil(
      try ModelContext(for: type, storageType: .file, shouldDeleteOldFile: false)
        .fetch(for: type)
        .first
    )
  }  

  func testEnumItem() throws {
    let context = try ModelContext(for: EnumItem.self)

    let newItem = EnumItem(
      plain: .foo,
      plains: [.foo, .bar],
      string: .foo,
      strings: [.foo, .bar],
      int: .foo,
      ints: [.foo, .bar],
      associatedValue: .foo("a"),
      associatedValues: [.foo("a"), .bar("1", 1), .baz(string: "2", int: 2), .qux(nil)],
      generic: EnumGeneric<String, Int>.foo("a"),
      generics: [.foo("a"), .bar(1)],
      optionalPlain: nil
    )

    context.insert(newItem)
    try context.save()
    
    try XCTAssertEqual(context.fetchCount(for: EnumItem.self), 1)
    
    let fetchedItem = try XCTUnwrap(
      context.fetch(for: EnumItem.self).first
    )
    XCTAssertEqual(fetchedItem.plain, .foo)
    XCTAssertEqual(fetchedItem.plains, [.foo, .bar])
    XCTAssertEqual(fetchedItem.string, .foo)
    XCTAssertEqual(fetchedItem.strings, [.foo, .bar])
    XCTAssertEqual(fetchedItem.int, .foo)
    XCTAssertEqual(fetchedItem.ints, [.foo, .bar])
    XCTAssertEqual(fetchedItem.associatedValue, .foo("a"))
    XCTAssertEqual(fetchedItem.associatedValues, [.foo("a"), .bar("1", 1), .baz(string: "2", int: 2), .qux(nil)])
    XCTAssertEqual(fetchedItem.generic, EnumGeneric<String, Int>.foo("a"))
    XCTAssertEqual(fetchedItem.generics, [EnumGeneric<String, Int>.foo("a"), .bar(1)])
    XCTAssertEqual(fetchedItem.optionalPlain, nil)
    
    newItem.optionalPlain = .foo
    try context.save()
    
    XCTAssertEqual(
      try context.fetch(for: EnumItem.self).first?.optionalPlain,
      .foo
    )
  }

  func testPersistentID() throws {
    let context = try ModelContext(for: SimpleItem.self, storageType: .file)

    let item = SimpleItem(value: 1)
    context.insert(item)
    try context.save()

    let otherItem = try XCTUnwrap(
      ModelContext(for: SimpleItem.self, storageType: .file, shouldDeleteOldFile: false)
        .fetch(for: SimpleItem.self)
        .first
    )

    // 一致する
    // e.g. `50ECC9B3-E716-4605-8F0A-9F34F171627C`
    XCTAssertEqual(
      item.persistentModelID.storeIdentifier,
      otherItem.persistentModelID.storeIdentifier
    )

    // 一致する
    // e.g. `ID(url: x-coredata://098062A1-E83A-41E0-9CA6-3898D6837347/SimpleItem/p1)`
    XCTAssertEqual(
      item.persistentModelID.id,
      otherItem.persistentModelID.id
    )

    // 一致する
    // e.g. `SimpleItem`
    XCTAssertEqual(
      item.persistentModelID.entityName,
      otherItem.persistentModelID.entityName
    )

    // 一致する
    XCTAssertEqual(
      item.persistentModelID.hashValue,
      otherItem.persistentModelID.hashValue
    )

    // ただし、 `persistentModelID.hashValue` が同一だが、`persistentModelID` 自体の Equatable は一致しない
    XCTAssertNotEqual(
      item.persistentModelID,
      otherItem.persistentModelID
    )

    let itemID = item.persistentModelID
    let otherID = otherItem.persistentModelID

    XCTAssertNotNil(
      try context.fetch(
        FetchDescriptor<SimpleItem>(
          predicate: #Predicate {
            $0.persistentModelID == itemID
          }
        )
      )
      .first
    )
    // Equatable で同値判定されないので、異なる context に対しては persistentModelID は意味がない
    XCTAssertNil(
      try context.fetch(
        FetchDescriptor<SimpleItem>(
          predicate: #Predicate {
            $0.persistentModelID == otherID
          }
        )
      )
      .first
    )
  }

  /// リレーションがあるモデルを追加した場合に、親と追加するか子を追加するかで persistentModelID が異なる
  func testPersistentIDWhenAddingParentModel() throws {
    typealias ParentItem = ExplicitOneToOneItem
    typealias ChildItem = ChildExplicitOneToOneItem
    
    let context = try ModelContext(for: ParentItem.self)
    
    let child = ChildItem(id: 1)
    let parent = ParentItem(id: 1, child: child)
    
    context.insert(parent)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)
    
    
    // parent.child.id と child.id が同一なことを確認
    XCTAssertEqual(
      parent.child?.id,
      child.id
    )
    // child.id が fetch したモデルと同一なことを確認
    XCTAssertEqual(
      child.id,
      try context.fetch(for: ChildItem.self).first?.id
    )
    
    // parent.persistentModelID は fetch した parent.persistentModelID は同一
    XCTAssertEqual(
      parent.persistentModelID,
      try context.fetch(for: ParentItem.self).first?.persistentModelID
    )
    // ⚠️ child.persistentModelID と fetch した child.persistentModelID は異なる
    XCTAssertNotEqual(
      // PersistentIdentifier(
      //   id: SwiftData.PersistentIdentifier.ID(
      //     url: x-coredata:///Child/tF7B18E54-5BB2-4DEC-B96A-B2C1CD0BDBA26
      //   ),
      //   implementation: SwiftData.PersistentIdentifierImplementation
      // )
      child.persistentModelID,
      // PersistentIdentifier(
      //   id: SwiftData.PersistentIdentifier.ID(
      //     url: x-coredata://97B640B8-8368-409C-ABFA-9C10CDDD9B5A/Child/p1
      //   ),
      //   implementation: SwiftData.PersistentIdentifierImplementation
      // )
      try context.fetch(for: ChildItem.self).first?.persistentModelID
    )

    // ⚠️ parent.child.persistentModelID と child.persistentModelID は異なる
    XCTAssertNotEqual(
      // SwiftData.PersistentIdentifier(
      //   id: SwiftData.PersistentIdentifier.ID(
      //     url: x-coredata://347B798F-07F4-41E0-973F-B81487FC2B24/Child/p1
      //   ),
      //   implementation: SwiftData.PersistentIdentifierImplementation
      // )
      parent.child?.persistentModelID,
      // SwiftData.PersistentIdentifier(
      //   id: SwiftData.PersistentIdentifier.ID(
      //     url: x-coredata:///Child/t2BF40D07-0D7B-46F1-ACD5-AA4F3A845DD52
      //   ),
      //   implementation: SwiftData.PersistentIdentifierImplementation
      // )
      child.persistentModelID
    )
    
    // 同一
    XCTAssertEqual(
      try XCTUnwrap(context.fetch(for: ParentItem.self).first?.child).persistentModelID,
      try XCTUnwrap(context.fetch(for: ChildItem.self).first).persistentModelID
    )
  }
  
  /// リレーションがあるモデルを追加した場合に、親と子のどちらかを insert するかで persistentModelID が異なる
  ///
  /// 子を追加した場合には以下となる
  /// - `child.persistentModelID` と `prent.child.persistentModelID` は同一
  /// - `parent.persistentModelID` とストレージに保存された `parent.persistentModelID` は異なる
  func testPersistentIDWhenAddingChildModel() throws {
    typealias ParentItem = ExplicitOneToOneItem
    typealias ChildItem = ChildExplicitOneToOneItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 10)
    let parent = ParentItem(id: 1, child: child)
    
    context.insert(child)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    let otherContext = try ModelContext(
      for: ParentItem.self,
      storageType: .file,
      shouldDeleteOldFile: false
    )

    // id は同一なことを確認できる
    XCTAssertEqual(
      child.id,
      try context.fetch(for: ChildItem.self).first?.id
    )
    XCTAssertEqual(
      parent.child?.id,
      child.id
    )

    // child.persistentModelID と fetch した child.persistentModelID は同一
    XCTAssertEqual(
      child.persistentModelID,
      try context.fetch(for: ChildItem.self).first?.persistentModelID
    )
    // child.persistentModelID と parent.child.persistentModelID は同一
    XCTAssertEqual(
      child.persistentModelID,
      parent.child?.persistentModelID
    )

    // ⚠️ parent.persistentModelID と child.parent.persistentModelID は異なる
    XCTAssertNotEqual(
      parent.persistentModelID,
      child.parent?.persistentModelID
    )
    // ⚠️ parent.persistentModelID と fetch した parent.persistentModelID は異なる
    XCTAssertNotEqual(
      parent.persistentModelID,
      try context.fetch(for: ParentItem.self).first?.persistentModelID
    )
    // child.parent.persistentModelID と fetch した parent.persistentModelID は同一
    // つまりは、parent.persistentModelID のみ異なるという結果になる。おそらく child.parent が DB に追加された場合にはオリジナルの parent とは異なる persistentModelID で採番されている。
    XCTAssertEqual(
      child.parent?.persistentModelID,
      try context.fetch(for: ParentItem.self).first?.persistentModelID
    )

    // 異なる context から取得した parent.persistentModelID と child.parent.persistentModelID は同一
    XCTAssertEqual(
      try XCTUnwrap(otherContext.fetch(for: ParentItem.self).first).persistentModelID,
      try XCTUnwrap(otherContext.fetch(for: ChildItem.self).first?.parent).persistentModelID
    )
  }
  
  func testInvalidInit() throws {
    let schema = Schema([SimpleItem.self])
    let modelConfiguration = ModelConfiguration(schema: schema)
    
    /// 使用したいモデルを `ModelContainer(for:configurations:)` に
    /// 渡す前に初期化しようとすると以下のランタイムエラーが発生する。
    ///
    /// Thread 1: Fatal error: failed to find a currently active container for SimpleItem
#if false
    _ = SimpleItem(value: 1)
#endif
    let modelContainer = try ModelContainer(
      for: SimpleItem.self,
      configurations: modelConfiguration
    )
    
    _ = SimpleItem(value: 1) // OK
  }
  
  func testUnsupportedType_UInt() throws {
    typealias Item = UnsupportedPropertyItemHasUInt
    
    /// `Int.max` を超える値を入れるとプロパティにアクセスした時にランタイムエラーが発生する。
    /// おそらく SQLite が signed integer のみサポートしているからだと思われる。
    ///
    /// ```
    /// Thread 1: EXC_BREAKPOINT (code=1, subcode=0x1c3c5ead8)
    /// ```
    let value = UInt(Int.max) // + 1
    
    let context = try ModelContext(for: Item.self)
    let item = Item(uint: value)
    
    XCTAssertEqual(item.uint, value)
    
    context.insert(item)
    try context.save()
        
    XCTAssertEqual(item.uint, value)
  }
}
