//
//  DeleteRuleCascadeItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/29.
//

import Foundation
import SwiftData

@Model
final class DeleteRuleCascadeOneToOneItem {
  
  @Attribute(.unique)
  var id: Int
  
  @Relationship(deleteRule: .cascade, inverse: \ChildDeleteRuleCascadeOneToOneItem.parent)
  var child: ChildDeleteRuleCascadeOneToOneItem?
  
  init(id: Int, child: ChildDeleteRuleCascadeOneToOneItem? = nil) {
    self.id = id
    self.child = child
  }
}

@Model
final class ChildDeleteRuleCascadeOneToOneItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: DeleteRuleCascadeOneToOneItem?
  
  init(id: Int, parent: DeleteRuleCascadeOneToOneItem? = nil) {
    self.id = id
    self.parent = parent
  }
}
