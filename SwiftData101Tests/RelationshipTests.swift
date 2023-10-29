//
//  RelationshipTests.swift
//  SwiftData101Tests
//
//  Created by yusuga on 2023/10/27.
//

import XCTest
import SwiftData
@testable import SwiftData101

final class RelationshipTests: XCTestCase {

  func testExplicitOneToOne() throws {
    let context = try ModelContext(for: ExplicitOneToOneItem.self)

    let child = ChildExplicitOneToOneItem(id: 10)
    let parent = ExplicitOneToOneItem(id: 1, child: child)
    
    // - Note: 保存前はアクセスできず、ランタイムエラーが発生
    // Thread 1: EXC_BREAKPOINT
    // XCTAssertNil(child.parent)
        
    context.insert(parent)
    try context.save()
    
    // parent と child が追加されていることを確認
    XCTAssertEqual(try context.fetchCount(for: ExplicitOneToOneItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitOneToOneItem.self), 1)

    // 保存後は child.parent に自動的に parent がセットされている
    XCTAssertEqual(child.parent?.persistentModelID, parent.persistentModelID)
    XCTAssertEqual(child.parent?.id, parent.id)
    
    // fetch した値にも parent がセットされている
    XCTAssertEqual(
      try context.fetch(for: ChildExplicitOneToOneItem.self).first?.parent?.persistentModelID,
      parent.persistentModelID
    )
    XCTAssertEqual(
      try context.fetch(for: ChildExplicitOneToOneItem.self).first?.parent?.id,
      parent.id
    )
    
    // parent を削除する
    context.delete(parent)
    try context.save()

    // parent は削除されている
    XCTAssertEqual(try context.fetchCount(for: ExplicitOneToOneItem.self), 0)
    // ただし、 child は削除されていない！これを自動的に削除するには Delete Rule の定義が必要
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitOneToOneItem.self), 1)
    
    // 自動的に child.parent が nil になる
    XCTAssertNil(child.parent)
    // fetch した child.parent も nil になっている
    XCTAssertNil(
      try XCTUnwrap(context.fetch(for: ChildExplicitOneToOneItem.self).first).parent
    )
  }
  
  func testInferredOneToOneItem() throws {
    let context = try ModelContext(for: InferredOneToOneItem.self)

    let child = ChildInferredOneToOneItem(id: 10)
    let parent = InferredOneToOneItem(id: 1, child: child)

    XCTAssertNil(parent.modelContext)

    // - Note: 保存前はアクセスできず、ランタイムエラーが発生
    // Thread 1: EXC_BREAKPOINT
    // XCTAssertNil(child.parent)

    context.insert(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: InferredOneToOneItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildInferredOneToOneItem.self), 1)
    
    XCTAssertNotNil(parent.modelContext) // save 後は modelContext が入る
    XCTAssertNil(child.modelContext) // こっちは nil
    
    // fetch したオブジェクトには含まれている
    XCTAssertNotNil(
      try XCTUnwrap(context.fetch(for: ChildInferredOneToOneItem.self).first).modelContext
    )

    // inverse が推測されて自動で値が入っている！不思議！
    XCTAssertEqual(child.parent?.id, parent.id)
    
    // fetch したオブジェクトにも inverse が入っている
    XCTAssertEqual(
      try XCTUnwrap(context.fetch(for: ChildInferredOneToOneItem.self).first).parent?.id,
      parent.id
    )

    context.delete(parent)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: InferredOneToOneItem.self), 0)
    XCTAssertEqual(try context.fetchCount(for: ChildInferredOneToOneItem.self), 1) // Child は存在する

    XCTAssertNil(parent.modelContext) // DB から削除されたので nil になる
    XCTAssertNil(parent.child)
    XCTAssertNil(child.parent) // inverse も自動で nil
    XCTAssertNil(
      try XCTUnwrap(context.fetch(for: ChildInferredOneToOneItem.self).first).parent
    )

    // 残調査
    // - inverse にできそうなものが複数あったらどうなるか
    // - inverse を明示的に入れたらどうなるか
    // - 1 : N だとどうなるか
  }
  
  func testExplicitOneToManyItem() throws {
    let context = try ModelContext(for: ExplicitOneToManyItem.self)

    let child1 = ChildExplicitOneToManyItem(id: 1)
    let child2 = ChildExplicitOneToManyItem(id: 2)
    let parent = ExplicitOneToManyItem(id: 1, children: [child1, child2])
    
    // - Note: 保存前はアクセスできず、ランタイムエラーが発生
    // Thread 1: EXC_BREAKPOINT
    // XCTAssertNil(child1.parent)

    context.insert(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ExplicitOneToManyItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitOneToManyItem.self), 2)

    // リレーションが定義されているので自動的に parent がセットされている
    XCTAssertEqual(child1.parent?.persistentModelID, parent.persistentModelID)
    XCTAssertEqual(child1.parent?.id, parent.id)
    XCTAssertEqual(child2.parent?.persistentModelID, parent.persistentModelID)
    XCTAssertEqual(child2.parent?.id, parent.id)
    try context.fetch(for: ChildExplicitOneToManyItem.self).forEach {
      XCTAssertEqual($0.parent?.persistentModelID, parent.persistentModelID)
      XCTAssertEqual($0.parent?.id, parent.id)
    }

    // child も自動的にセットされている
    XCTAssertEqual(
      Set(parent.children.map { $0.id }),
      Set([child1, child2].map { $0.id })
    )
    XCTAssertEqual(
      try Set(context.fetch(for: ChildExplicitOneToManyItem.self).map { $0.id }),
      Set([child1, child2].map { $0.id })
    )
    
    // ただし、この追加方法では persistentModelID は不一致になる
    XCTAssertNotEqual(
      Set(parent.children.map { $0.persistentModelID }),
      Set([child1, child2].map { $0.persistentModelID })
    )
    XCTAssertNotEqual(
      try Set(context.fetch(for: ChildExplicitOneToManyItem.self).map { $0.persistentModelID }),
      Set([child1, child2].map { $0.persistentModelID })
    )
    
    // parent を削除
    context.delete(parent)
    try context.save()
    
    // 削除されていることを確認
    XCTAssertEqual(try context.fetchCount(for: ExplicitOneToManyItem.self), 0)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitOneToManyItem.self), 2)
    
    // リレーションが設定されているので自動的に nil になる
    XCTAssertNil(child1.parent)
    XCTAssertNil(child2.parent)
    try context.fetch(for: ChildExplicitOneToManyItem.self).forEach {
      XCTAssertNil($0.parent)
    }
  }
  
  func testInferredOneToManyItem() throws {
    let context = try ModelContext(for: InferredOneToManyItem.self)

    let child1 = ChildInferredOneToManyItem(id: 1)
    let child2 = ChildInferredOneToManyItem(id: 2)
    let parent = InferredOneToManyItem(id: 1, children: [child1, child2])
    
    // - Note: 保存前はアクセスできず、ランタイムエラーが発生
    // Thread 1: EXC_BREAKPOINT
    // XCTAssertNil(child1.parent)

    context.insert(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: InferredOneToManyItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildInferredOneToManyItem.self), 2)

    XCTAssertEqual(child1.parent?.id, parent.id)
    XCTAssertEqual(child2.parent?.id, parent.id)
    try context.fetch(for: ChildInferredOneToManyItem.self).forEach {
      XCTAssertEqual($0.parent?.id, parent.id)
    }
    
    XCTAssertEqual(
      Set(parent.children.map { $0.id }),
      Set([child1, child2].map { $0.id })
    )
    XCTAssertEqual(
      try Set(context.fetch(for: ChildInferredOneToManyItem.self).map { $0.id }),
      Set([child1, child2].map { $0.id })
    )
    
    context.delete(parent)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: InferredOneToManyItem.self), 0)
    XCTAssertEqual(try context.fetchCount(for: ChildInferredOneToManyItem.self), 2)
    
    XCTAssertNil(child1.parent)
    XCTAssertNil(child2.parent)
    try context.fetch(for: ChildInferredOneToManyItem.self).forEach {
      XCTAssertNil($0.parent)
    }
  }
    
  func testExplicitManyToManyItem_初期化後にリレーションを追加() throws {
    let context = try ModelContext(for: ExplicitManyToManyItem.self)

    let parent1 = ExplicitManyToManyItem(id: 1)
    let parent2 = ExplicitManyToManyItem(id: 2)
    let child = ChildExplicitManyToManyItem(id: 1)
    
    // 先にモデルを追加する
    context.insert(parent1)
    context.insert(parent2)
    context.insert(child)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: ExplicitManyToManyItem.self), 2)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitManyToManyItem.self), 1)
    XCTAssertTrue(parent1.children.isEmpty)
    XCTAssertTrue(parent2.children.isEmpty)
    XCTAssertTrue(child.parents.isEmpty)
    
    // parent に child を追加
    parent1.children.append(child)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: ExplicitManyToManyItem.self), 2)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitManyToManyItem.self), 1)
    
    XCTAssertTrue(parent1.children.contains(child))
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ExplicitManyToManyItem.self, id: parent1.persistentModelID)
      )
      .children.contains(child)
    )
    
    // inverse が自動で反映されている
    XCTAssertTrue(child.parents.contains(parent1))
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ChildExplicitManyToManyItem.self, id: child.persistentModelID)
      )
      .parents.contains(parent1)
    )
    
    XCTAssertFalse(child.parents.contains(parent2))
    
    // child に parent を追加
    child.parents.append(parent2)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: ExplicitManyToManyItem.self), 2)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitManyToManyItem.self), 1)

    XCTAssertTrue(parent2.children.contains(child))
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ExplicitManyToManyItem.self, id: parent2.persistentModelID)
      )
      .children.contains(child)
    )
    
    // inverse が自動で反映されている
    XCTAssertTrue(child.parents.contains(parent2))
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ChildExplicitManyToManyItem.self, id: child.persistentModelID)
      )
      .parents.contains(parent2)
    )
    
    // parent1 から child へのリレーションを削除
    parent1.children.removeAll()
    try context.save()
    
    XCTAssertTrue(parent1.children.isEmpty)
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ExplicitManyToManyItem.self, id: parent1.persistentModelID)
      )
      .children.isEmpty
    )
    
    // inverse でも parent が取り除かれる
    XCTAssertFalse(child.parents.contains(parent1))
    XCTAssertFalse(
      try XCTUnwrap(
        context.fetch(for: ChildExplicitManyToManyItem.self, id: child.persistentModelID)
      )
      .parents.contains(parent1)
    )
    
    XCTAssertTrue(child.parents.contains(parent2))
    
    // child から parent へのリレーションを削除
    child.parents.removeAll()
    try context.save()
    
    // inverse でも child が取り除かれる
    XCTAssertTrue(parent2.children.isEmpty)
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ExplicitManyToManyItem.self, id: parent2.persistentModelID)
      )
      .children.isEmpty
    )
    
    XCTAssertTrue(child.parents.isEmpty)
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ChildExplicitManyToManyItem.self, id: child.persistentModelID)
      )
      .parents.isEmpty
    )
    
    // リレーションを削除しただけなので DB 自体には値は残っている
    XCTAssertEqual(try context.fetchCount(for: ExplicitManyToManyItem.self), 2)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitManyToManyItem.self), 1)
  }
  
  func testExplicitManyToManyItem_初期化時にリレーションを追加する() throws {
    let context = try ModelContext(for: ExplicitManyToManyItem.self)
        
    let child = ChildExplicitManyToManyItem(id: 1)
    let parent1 = ExplicitManyToManyItem(id: 1, children: [child])
    
    /// - Note: 以下は `Thread 1: EXC_BREAKPOINT (code=1, subcode=0x1c3c6203c)` が発生する
    ///         推察される理由は、すでに parent1 と child がリレーションが構築されるようとしている中で、
    ///         `child` に対してさらに parent2 のリレーションを構築しようとして、child.parents にアクセスしようとしているから。
    // let parent2 = ExplicitManyToManyItem(id: 2, children: [child])
          
    context.insert(parent1)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: ExplicitManyToManyItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitManyToManyItem.self), 1)
    
    XCTAssertTrue(parent1.children.map { $0.id }.contains(child.id))
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ExplicitManyToManyItem.self, id: parent1.persistentModelID)
      )
      .children.map { $0.id }.contains(child.id)
    )
    
    // inverse が自動で反映されている
    XCTAssertTrue(child.parents.map { $0.id }.contains(parent1.id))
    XCTAssertTrue(
      try XCTUnwrap(context.fetchManyToManyItemChild(for: child.id))
        .parents.map { $0.id }
        .contains(parent1.id)
    )
    
    /// - Note: 以下は `Illegal attempt to establish a relationship 'parents' between objects in different contexts` が発生する。
    ///         推察される理由は、 `child` はすでに `modelContext` に紐付いている状態で、まだ `modelContext` に紐付いていない `parent2` に対してリレーションを構築しようとしているため。
    // let parent2 = ExplicitManyToManyItem(id: 2, children: [child])
    
    let parent2 = ExplicitManyToManyItem(id: 2)
    context.insert(parent2)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ExplicitManyToManyItem.self), 2)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitManyToManyItem.self), 1)
    
    XCTAssertFalse(child.parents.map { $0.id }.contains(parent2.id))
    
    // child に parent を追加
    child.parents.append(parent2)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: ExplicitManyToManyItem.self), 2)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitManyToManyItem.self), 1)

    XCTAssertTrue(parent2.children.map { $0.id }.contains(child.id))
    XCTAssertTrue(
      try XCTUnwrap(context.fetchManyToManyItem(for: parent2.id))
        .children.map { $0.id }
        .contains(child.id)
    )
    
    // inverse が自動で反映されている
    XCTAssertTrue(child.parents.contains(parent2))
    XCTAssertTrue(
      try XCTUnwrap(context.fetchManyToManyItemChild(for: child.id))
        .parents.map { $0.id }
        .contains(parent2.id)
    )
    
    // parent1 から child へのリレーションを削除
    parent1.children.removeAll()
    try context.save()
    
    XCTAssertTrue(parent1.children.isEmpty)
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetchManyToManyItem(for: parent1.id)
      )
      .children.isEmpty
    )
    
    // inverse でも parent が取り除かれる
    XCTAssertFalse(child.parents.contains(parent1))
    XCTAssertFalse(
      try XCTUnwrap(context.fetchManyToManyItemChild(for: child.id))
        .parents.map { $0.id }
        .contains(parent1.id)
    )
    
    XCTAssertTrue(child.parents.contains(parent2))
    
    // child から parent へのリレーションを削除
    child.parents.removeAll()
    try context.save()
    
    // inverse でも child が取り除かれる
    XCTAssertTrue(parent2.children.isEmpty)
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: ExplicitManyToManyItem.self, id: parent2.persistentModelID)
      )
      .children.isEmpty
    )
    
    XCTAssertTrue(child.parents.isEmpty)
    XCTAssertTrue(
      try XCTUnwrap(context.fetchManyToManyItemChild(for: child.id))
        .parents.isEmpty
    )
    
    // リレーションを削除しただけなので DB 自体には値は残っている
    XCTAssertEqual(try context.fetchCount(for: ExplicitManyToManyItem.self), 2)
    XCTAssertEqual(try context.fetchCount(for: ChildExplicitManyToManyItem.self), 1)
  }
  
  func testInferredManyToManyItem() throws {
    let context = try ModelContext(for: InvalidInferredManyToManyItem.self)

    let parent = InvalidInferredManyToManyItem(id: 1)
    let childID = 1
    let child = ChildInvalidInferredManyToManyItem(id: childID)
    
    // 先にモデルを追加する
    context.insert(parent)
    context.insert(child)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: InvalidInferredManyToManyItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildInvalidInferredManyToManyItem.self), 1)
    XCTAssertTrue(parent.children.isEmpty)
    XCTAssertTrue(child.parents.isEmpty)
    
    // parent に child を追加
    parent.children.append(child)
    try context.save()
    
    XCTAssertTrue(parent.children.contains(child))
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetch(for: InvalidInferredManyToManyItem.self, id: parent.persistentModelID)
      )
      .children.contains(child)
    )
    
    // inverse が自動で反映されない
    XCTAssertFalse(child.parents.contains(parent))
    XCTAssertFalse(child.parents.map { $0.id }.contains(parent.id))
    XCTAssertFalse(
      try XCTUnwrap(
        context.fetch(for: ChildInvalidInferredManyToManyItem.self, id: child.persistentModelID)
      )
      .parents.contains(parent)
    )
    XCTAssertFalse(
      try XCTUnwrap(
        context.fetch(
          FetchDescriptor<ChildInvalidInferredManyToManyItem>(
            predicate: #Predicate {
              $0.id == childID
            }
          )
        )
        .first
      )
      .parents.map { $0.id }.contains(parent.id)
    )
  }
}

private extension ModelContext {

  func fetchManyToManyItem<Model>(
    for id: Int
  ) throws -> Model? where Model: ExplicitManyToManyItem {
    var fetchDescriptor = FetchDescriptor<Model>(
      predicate: #Predicate {
        $0.id == id
      }
    )
    fetchDescriptor.fetchLimit = 1
    
    return try fetch(fetchDescriptor).first
  }
  
  func fetchManyToManyItemChild<Model>(
    for id: Int
  ) throws -> Model? where Model: ChildExplicitManyToManyItem {
    var fetchDescriptor = FetchDescriptor<Model>(
      predicate: #Predicate {
        $0.id == id
      }
    )
    fetchDescriptor.fetchLimit = 1
    
    return try fetch(fetchDescriptor).first
  }
}
