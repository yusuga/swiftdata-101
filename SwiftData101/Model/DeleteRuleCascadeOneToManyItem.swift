//
//  DeleteRuleCascadeOneToManyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/29.
//

import Foundation
import SwiftData

@Model
final class DeleteRuleCascadeOneToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  @Relationship(deleteRule: .cascade, inverse: \ChildDeleteRuleCascadeOneToManyItem.parent)
  var children: [ChildDeleteRuleCascadeOneToManyItem] = []
  
  init(id: Int, children: [ChildDeleteRuleCascadeOneToManyItem] = []) {
    self.id = id
    self.children = children
  }
}

@Model
final class ChildDeleteRuleCascadeOneToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: DeleteRuleCascadeOneToManyItem?
  
  init(id: Int) {
    self.id = id
  }
}
