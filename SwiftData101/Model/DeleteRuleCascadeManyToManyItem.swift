//
//  DeleteRuleCascadeManyToManyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/29.
//

import Foundation
import SwiftData

@Model
final class DeleteRuleCascadeManyToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  @Relationship(deleteRule: .cascade, inverse: \ChildDeleteRuleCascadeManyToManyItem.parents)
  var children: [ChildDeleteRuleCascadeManyToManyItem] = []
  
  init(id: Int, children: [ChildDeleteRuleCascadeManyToManyItem] = []) {
    self.id = id
    self.children = children
  }
}

@Model
final class ChildDeleteRuleCascadeManyToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parents: [DeleteRuleCascadeManyToManyItem] = []
  
  init(id: Int, parents: [DeleteRuleCascadeManyToManyItem] = []) {
    self.id = id
    self.parents = parents
  }
}
