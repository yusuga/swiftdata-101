//
//  DeleteRuleNoActionItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/11/05.
//

import Foundation
import SwiftData

@Model
final class DeleteRuleNoActionItem {
  
  @Attribute(.unique)
  var id: Int
  
  @Relationship(deleteRule: .noAction, inverse: \ChildDeleteRuleNoActionItem.parent)
  var child: ChildDeleteRuleNoActionItem?
  
  init(id: Int, child: ChildDeleteRuleNoActionItem?) {
    self.id = id
    self.child = child
  }
}
  
@Model
final class ChildDeleteRuleNoActionItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: DeleteRuleNoActionItem?
  
  init(id: Int) {
    self.id = id
  }
}
