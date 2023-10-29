//
//  DeleteRuleTests.swift
//  SwiftData101Tests
//
//  Created by yusuga on 2023/10/29.
//

import XCTest
import SwiftData
@testable import SwiftData101

final class DeleteRuleTests: XCTestCase {
  
  func testCascade_OneToOneRelation_初期化時に子のリレーションをセット_子をinsert() throws {
    typealias ParentItem = DeleteRuleCascadeOneToOneItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToOneItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 10)
    let parent = ParentItem(id: 1, child: child)
    
    /// - Note: `context.insert(parent)` を追加するとその `context` では `cascade delete` されない
    context.insert(child)
    try context.save()
    
    let otherContext = try ModelContext(for: ParentItem.self, storageType: .file, shouldDeleteOldFile: false)
    let otherParent = try XCTUnwrap(otherContext.fetch(for: ParentItem.self).first)
    let otherChild = try XCTUnwrap(otherContext.fetch(for: ChildItem.self).first)

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    /* リレーション間で ChildItem.persistentModelID が一致するかを確認 */
    
    // child.id が一致する
    XCTAssertEqual(child.id, parent.child?.id)
    XCTAssertEqual(child.id, try context.fetch(for: ChildItem.self).first?.id)
    
    // child.persistentModelID が一致する
    XCTAssertEqual(child.persistentModelID, parent.child?.persistentModelID)
    XCTAssertEqual(child.persistentModelID, try context.fetch(for: ChildItem.self).first?.persistentModelID)
        
    // 異なる context でも child.persistentModelID が一致する
    XCTAssertEqual(otherChild.persistentModelID, otherParent.child?.persistentModelID)
        
    /* リレーション間で ParentItem.persistentModelID が一致するかを確認 */
    
    // parent.id が一致する
    XCTAssertEqual(parent.id, child.parent?.id)
    XCTAssertEqual(parent.id, try context.fetch(for: ChildItem.self).first?.parent?.id)
    
    // ⚠️ parent.persistentModelID が異なる
    XCTAssertNotEqual(parent.persistentModelID, child.parent?.persistentModelID)
    XCTAssertNotEqual(parent.persistentModelID, try context.fetch(for: ChildItem.self).first?.parent?.persistentModelID)
    
    // ⚠️ 異なる context では otherParent.persistentModelID が一致する
    XCTAssertEqual(otherParent.persistentModelID, otherChild.parent?.persistentModelID)
    
    context.delete(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 0)
    
    // cascade delete される
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 0)
    XCTAssertEqual(try context.fetch(for: ChildItem.self).count, 0)
  }
  
  func testCascade_OneToOneRelation_初期化時に親のリレーションをセット_子をinsert() throws {
    typealias ParentItem = DeleteRuleCascadeOneToOneItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToOneItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let parent = ParentItem(id: 1)
    let child = ChildItem(id: 10, parent: parent)
    
    /// - Note: `context.insert(parent)` を追加するとその `context` では `cascade delete` されない
    context.insert(child)
    try context.save()
    
    let otherContext = try ModelContext(for: ParentItem.self, storageType: .file, shouldDeleteOldFile: false)
    let otherParent = try XCTUnwrap(otherContext.fetch(for: ParentItem.self).first)
    let otherChild = try XCTUnwrap(otherContext.fetch(for: ChildItem.self).first)

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    /* リレーション間で ChildItem.persistentModelID が一致するかを確認 */
    
    // child.id が一致する
    XCTAssertEqual(child.id, parent.child?.id)
    XCTAssertEqual(child.id, try context.fetch(for: ChildItem.self).first?.id)
    
    // child.persistentModelID が一致する
    XCTAssertEqual(child.persistentModelID, parent.child?.persistentModelID)
    XCTAssertEqual(child.persistentModelID, try context.fetch(for: ChildItem.self).first?.persistentModelID)
        
    // 異なる context でも child.persistentModelID が一致する
    XCTAssertEqual(otherChild.persistentModelID, otherParent.child?.persistentModelID)
        
    /* リレーション間で ParentItem.persistentModelID が一致するかを確認 */
    
    // parent.id が一致する
    XCTAssertEqual(parent.id, child.parent?.id)
    XCTAssertEqual(parent.id, try context.fetch(for: ChildItem.self).first?.parent?.id)
    
    // ⚠️ parent.persistentModelID が異なる
    XCTAssertNotEqual(parent.persistentModelID, child.parent?.persistentModelID)
    XCTAssertNotEqual(parent.persistentModelID, try context.fetch(for: ChildItem.self).first?.parent?.persistentModelID)
    
    // ⚠️ 異なる context では otherParent.persistentModelID が一致する
    XCTAssertEqual(otherParent.persistentModelID, otherChild.parent?.persistentModelID)
    
    context.delete(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 0)
    
    // cascade delete される
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 0)
    XCTAssertEqual(try context.fetch(for: ChildItem.self).count, 0)
  }
  
  func testCascade_OneToOneRelation_初期化時に子のリレーションをセット_親を追加_同一contextで削除() throws {
    typealias ParentItem = DeleteRuleCascadeOneToOneItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToOneItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 10)
    let parent = ParentItem(id: 1, child: child)
    
    context.insert(parent)
    try context.save()
    
    let otherContext = try ModelContext(for: ParentItem.self, storageType: .file, shouldDeleteOldFile: false)
    let otherParent = try XCTUnwrap(otherContext.fetch(for: ParentItem.self).first)
    let otherChild = try XCTUnwrap(otherContext.fetch(for: ChildItem.self).first)

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    /* リレーション間で ChildItem.persistentModelID が一致するかを確認 */
    
    // child.id が一致する
    XCTAssertEqual(child.id, parent.child?.id)
    XCTAssertEqual(child.id, try context.fetch(for: ChildItem.self).first?.id)
    
    // ⚠️ child.persistentModelID が一致しない
    XCTAssertNotEqual(child.persistentModelID, parent.child?.persistentModelID)
    XCTAssertNotEqual(child.persistentModelID, try context.fetch(for: ChildItem.self).first?.persistentModelID)
        
    // ⚠️ 異なる context では child.persistentModelID が一致する
    XCTAssertEqual(otherChild.persistentModelID, otherParent.child?.persistentModelID)
        
    /* リレーション間で ParentItem.persistentModelID が一致するかを確認 */
    
    // parent.id が一致する
    XCTAssertEqual(parent.id, child.parent?.id)
    XCTAssertEqual(parent.id, try context.fetch(for: ChildItem.self).first?.parent?.id)
    
    // parent.persistentModelID が一致する
    XCTAssertEqual(parent.persistentModelID, child.parent?.persistentModelID)
    XCTAssertEqual(parent.persistentModelID, try context.fetch(for: ChildItem.self).first?.parent?.persistentModelID)
    
    //異なる context でも otherParent.persistentModelID が一致する
    XCTAssertEqual(otherParent.persistentModelID, otherChild.parent?.persistentModelID)
    
    context.delete(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 0)
    
    // ⚠️ cascade delete されない
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)
    XCTAssertEqual(try context.fetch(for: ChildItem.self).count, 1)
  }
  
  func testCascade_OneToOneRelation_初期化時に子のリレーションを追加_親をinsert_異なるcontextで削除() throws {
    typealias ParentItem = DeleteRuleCascadeOneToOneItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToOneItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 10)
    let parent = ParentItem(id: 1, child: child)
    
    context.insert(parent)
    try context.save()
    
    let otherContext = try ModelContext(for: ParentItem.self, storageType: .file, shouldDeleteOldFile: false)
    let otherParent = try XCTUnwrap(otherContext.fetch(for: ParentItem.self).first)
    let otherChild = try XCTUnwrap(otherContext.fetch(for: ChildItem.self).first)

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    /* リレーション間で ChildItem.persistentModelID が一致するかを確認 */
    
    // child.id が一致する
    XCTAssertEqual(child.id, parent.child?.id)
    XCTAssertEqual(child.id, try context.fetch(for: ChildItem.self).first?.id)
    
    // ⚠️ child.persistentModelID が一致しない
    XCTAssertNotEqual(child.persistentModelID, parent.child?.persistentModelID)
    XCTAssertNotEqual(child.persistentModelID, try context.fetch(for: ChildItem.self).first?.persistentModelID)
        
    // ⚠️ 異なる context では child.persistentModelID が一致する
    XCTAssertEqual(otherChild.persistentModelID, otherParent.child?.persistentModelID)
        
    /* リレーション間で ParentItem.persistentModelID が一致するかを確認 */
    
    // parent.id が一致する
    XCTAssertEqual(parent.id, child.parent?.id)
    XCTAssertEqual(parent.id, try context.fetch(for: ChildItem.self).first?.parent?.id)
    
    // parent.persistentModelID が一致する
    XCTAssertEqual(parent.persistentModelID, child.parent?.persistentModelID)
    XCTAssertEqual(parent.persistentModelID, try context.fetch(for: ChildItem.self).first?.parent?.persistentModelID)
    
    //異なる context でも otherParent.persistentModelID が一致する
    XCTAssertEqual(otherParent.persistentModelID, otherChild.parent?.persistentModelID)
    
    // 異なる context でも結果は変わらず cascade delete されない
    otherContext.delete(otherParent)
    try otherContext.save()
    
    XCTAssertEqual(try otherContext.fetchCount(for: ParentItem.self), 0)
     
    // ⚠️ cascade delete されない
    XCTAssertEqual(try otherContext.fetchCount(for: ChildItem.self), 1)
    XCTAssertEqual(try otherContext.fetch(for: ChildItem.self).count, 1)
  }
  
  func testCascade_OneToOneRelation_初期化時に子を追加しない() throws {
    typealias ParentItem = DeleteRuleCascadeOneToOneItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToOneItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 10)
    let parent = ParentItem(id: 1)
    
    context.insert(parent)
    context.insert(child)
    parent.child = child
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    let otherContext = try ModelContext(for: ParentItem.self, storageType: .file, shouldDeleteOldFile: false)
    let otherParent = try XCTUnwrap(otherContext.fetch(for: ParentItem.self).first)
    let otherChild = try XCTUnwrap(otherContext.fetch(for: ChildItem.self).first)

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    /* リレーション間で ChildItem.persistentModelID が一致するかを確認 */
    
    // child.id が一致する
    XCTAssertEqual(child.id, parent.child?.id)
    XCTAssertEqual(child.id, try context.fetch(for: ChildItem.self).first?.id)
    
    // child.persistentModelID が一致する
    XCTAssertEqual(child.persistentModelID, parent.child?.persistentModelID)
    XCTAssertEqual(child.persistentModelID, try context.fetch(for: ChildItem.self).first?.persistentModelID)
        
    // 異なる context でも child.persistentModelID が一致する
    XCTAssertEqual(otherChild.persistentModelID, otherParent.child?.persistentModelID)
        
    /* リレーション間で ParentItem.persistentModelID が一致するかを確認 */
    
    // parent.id が一致する
    XCTAssertEqual(parent.id, child.parent?.id)
    XCTAssertEqual(parent.id, try context.fetch(for: ChildItem.self).first?.parent?.id)
    
    // parent.persistentModelID が一致する
    XCTAssertEqual(parent.persistentModelID, child.parent?.persistentModelID)
    XCTAssertEqual(parent.persistentModelID, try context.fetch(for: ChildItem.self).first?.parent?.persistentModelID)
    
    // 異なる context でも child.persistentModelID が一致する
    XCTAssertEqual(otherParent.persistentModelID, otherChild.parent?.persistentModelID)
    
#if true
    // parent を削除する
    context.delete(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 0)
    
    // ⚠️ cascade delete されない
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)
    XCTAssertEqual(try context.fetch(for: ChildItem.self).count, 1)
#else
    // 異なる context でも結果は変わらない
    otherContext.delete(otherParent)
    try otherContext.save()
    
    XCTAssertEqual(try otherContext.fetchCount(for: ParentItem.self), 0)
     
    // ⚠️ cascade delete されない
    XCTAssertEqual(try otherContext.fetchCount(for: ChildItem.self), 1)
    XCTAssertEqual(try otherContext.fetch(for: ChildItem.self).count, 1)
#endif
  }
  func testCascadeDeleteOneToMany_childを追加する() throws {
    typealias ParentItem = DeleteRuleCascadeOneToManyItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToManyItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 10)
    let parent = ParentItem(id: 1, children: [child])
    
    /// - Note: `context.insert(parent)` を追加するとその `context` では `cascade delete` されない
    context.insert(child)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    // inverse
    XCTAssertEqual(child.parent?.id, parent.id)
    XCTAssertEqual(try context.fetch(for: ChildItem.self).first?.parent?.id, parent.id)
    
    context.delete(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 0)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 0)
  }
  
  func testCascadeDeleteOneToMany_parentを追加して同一contextから削除する() throws {
    typealias ParentItem = DeleteRuleCascadeOneToManyItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToManyItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 1)
    let parent = ParentItem(id: 1, children: [child])
    
    /// - Note: `context.insert(parent)` を追加したので、その `context` では `cascade delete` させることが難しくなる
    context.insert(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    // inverse
    XCTAssertEqual(child.parent?.id, parent.id)
    XCTAssertEqual(try context.fetch(for: ChildItem.self).first?.parent?.id, parent.id)

    // 以下では ChildItem が cascade delete されない
    /*
    context.delete(parent)
    try context.save()
     */
    
    // 以下では ChildItem が cascade delete されない
    /*
    context.delete(
      try XCTUnwrap(context.fetch(for: ParentItem.self).first)
    )
    try context.save()
     */
    
    // 以下では ChildItem が cascade delete されない
    /*
    context.delete(
      try XCTUnwrap(child.parent)
    )
    try context.save()
     */
    
    // 同一 context からはこの方法でしか ChildItem を cascade delete できない（はず
    try context.delete(model: ParentItem.self)
    
    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 0)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 0)
  }
  
  func testCascadeDeleteOneToMany_parentを追加して異なるcontextから削除する() throws {
    typealias ParentItem = DeleteRuleCascadeOneToManyItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToManyItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 1)
    let parent = ParentItem(id: 1, children: [child])
    
    context.insert(parent)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    // inverse
    XCTAssertEqual(child.parent?.id, parent.id)
    XCTAssertEqual(try context.fetch(for: ChildItem.self).first?.parent?.id, parent.id)
    
    let otherContext = try ModelContext(
      for: ParentItem.self,
      storageType: .file,
      shouldDeleteOldFile: false
    )
    
    XCTAssertEqual(try otherContext.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try otherContext.fetchCount(for: ChildItem.self), 1)

    // 異なる context からなら cascade delete される
    otherContext.delete(
      try XCTUnwrap(
        otherContext.fetch(for: ParentItem.self).first
      )
    )
    try context.save()

    XCTAssertEqual(try otherContext.fetchCount(for: ParentItem.self), 0)
    XCTAssertEqual(try otherContext.fetchCount(for: ChildItem.self), 0)
  }
  
  func testCascadeDeleteOneToMany_childを追加して異なるcontextから削除する() throws {
    typealias ParentItem = DeleteRuleCascadeOneToManyItem
    typealias ChildItem = ChildDeleteRuleCascadeOneToManyItem
    
    let context = try ModelContext(for: ParentItem.self, storageType: .file)

    let child = ChildItem(id: 1)
    let parent = ParentItem(id: 1, children: [child])
    
    context.insert(child)
    try context.save()

    XCTAssertEqual(try context.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildItem.self), 1)

    // inverse
    XCTAssertEqual(child.parent?.id, parent.id)
    XCTAssertEqual(try context.fetch(for: ChildItem.self).first?.parent?.id, parent.id)
    
    let otherContext = try ModelContext(
      for: ParentItem.self,
      storageType: .file,
      shouldDeleteOldFile: false
    )
    
    XCTAssertEqual(try otherContext.fetchCount(for: ParentItem.self), 1)
    XCTAssertEqual(try otherContext.fetchCount(for: ChildItem.self), 1)

    // 異なる context からなら cascade delete される
    otherContext.delete(
      try XCTUnwrap(
        otherContext.fetch(for: ParentItem.self).first
      )
    )
    try context.save()

    XCTAssertEqual(try otherContext.fetchCount(for: ParentItem.self), 0)
    XCTAssertEqual(try otherContext.fetchCount(for: ChildItem.self), 0)
  }
  
  func testDeleteRuleCascadeManyToManyItem() throws {
    let context = try ModelContext(for: DeleteRuleCascadeManyToManyItem.self)
        
    let child = ChildDeleteRuleCascadeManyToManyItem(id: 10)
    let parent = DeleteRuleCascadeManyToManyItem(id: 1, children: [child])
    
    /// - Note: `N:N` の場合は `parent` or `child` のどちらを追加しても `cascade delete` される
#if true
    context.insert(parent)
#else
    context.insert(child)
#endif
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: DeleteRuleCascadeManyToManyItem.self), 1)
    XCTAssertEqual(try context.fetchCount(for: ChildDeleteRuleCascadeManyToManyItem.self), 1)
    
    XCTAssertTrue(parent.children.map { $0.id }.contains(child.id))
    XCTAssertTrue(
      try XCTUnwrap(
        context.fetchManyToManyItem(for: parent.id)
      )
      .children.map { $0.id }.contains(child.id)
    )
    
    // inverse が自動で反映されている
    XCTAssertTrue(child.parents.map { $0.id }.contains(parent.id))
    XCTAssertTrue(
      try XCTUnwrap(context.fetchManyToManyItemChild(for: child.id))
        .parents.map { $0.id }
        .contains(parent.id)
    )
        
    context.delete(parent)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: DeleteRuleCascadeManyToManyItem.self), 0)
    XCTAssertEqual(try context.fetchCount(for: ChildDeleteRuleCascadeManyToManyItem.self), 0)
  }
  
  func testDeleteRuleNullify() throws {
    typealias Parent = DeleteRuleNullifyItem
    typealias Child = ChildDeleteRuleNullifyItem
    
    let context = try ModelContext(for: Parent.self)
    
    let child = Child(id: 10)
    let parent = Parent(id: 1, child: child)

    context.insert(parent)
    try context.save()

    XCTAssertNotNil(parent.child)
    XCTAssertNotNil(child.parent)
    
    context.delete(parent)
    try context.save()
    
    // `DeleteRule.nullify` によって自動的に nil になる
    XCTAssertNil(child.parent)
  }
  
  func testDeleteRuleNoAction() throws {
    typealias Parent = DeleteRuleNoActionItem
    typealias Child = ChildDeleteRuleNoActionItem
    
    let context = try ModelContext(for: Parent.self)
    
    let child = Child(id: 10)
    let parent = Parent(id: 1, child: child)

    context.insert(parent)
    try context.save()

    XCTAssertNotNil(parent.child)
    XCTAssertNotNil(child.parent)

#if true
    /// - Note: parent を削除する前に明示的に nil にしないとランタイムエラーで `EXC_BAD_ACCESS` が発生してしまう。
    child.parent = nil
#endif
    context.delete(parent)

    try context.save()
    
    // NoAction なので NotNil になるのかもしれませんが、ランタイムエラーが発生するため検証できず
    XCTAssertNil(child.parent)
  }
  
  func testDeleteRuleDeny() throws {
    typealias Parent = DeleteRuleDenyItem
    typealias Child = ChildDeleteRuleDenyItem
    
    let context = try ModelContext(for: Parent.self)
    
    let child = Child(id: 10)
    let parent = Parent(id: 1, children: [child])

    context.insert(parent)
    try context.save()

    XCTAssertFalse(parent.children.isEmpty)
    XCTAssertNotNil(child.parent)
    
    context.delete(parent)
    
    /// `parent.children` に値があるため削除できずエラーがスローされる
    ///
    /// `NSLocalizedDescription=Items cannot be deleted from %{PROPERTY}@.`
    XCTAssertThrowsError(
      try context.save()
    )
    
    context.delete(child)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: Child.self), 0)
    
    /// child を削除したので parent も削除可能になった
    context.delete(parent)
    try context.save()
    
    XCTAssertEqual(try context.fetchCount(for: Parent.self), 0)
  }
}

private extension ModelContext {

  func fetchManyToManyItem<Model>(
    for id: Int
  ) throws -> Model? where Model: DeleteRuleCascadeManyToManyItem {
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
  ) throws -> Model? where Model: ChildDeleteRuleCascadeManyToManyItem {
    var fetchDescriptor = FetchDescriptor<Model>(
      predicate: #Predicate {
        $0.id == id
      }
    )
    fetchDescriptor.fetchLimit = 1
    
    return try fetch(fetchDescriptor).first
  }
}
