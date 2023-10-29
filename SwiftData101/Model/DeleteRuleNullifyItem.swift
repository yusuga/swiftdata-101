//
//  DeleteRuleNullifyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/11/05.
//

import Foundation
import SwiftData

@Model
final class DeleteRuleNullifyItem {
  
  @Attribute(.unique)
  var id: Int
  
  @Relationship(deleteRule: .nullify, inverse: \ChildDeleteRuleNullifyItem.parent)
  var child: ChildDeleteRuleNullifyItem?
  
  init(id: Int, child: ChildDeleteRuleNullifyItem?) {
    self.id = id
    self.child = child
  }
}
  
@Model
final class ChildDeleteRuleNullifyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: DeleteRuleNullifyItem?
  
  init(id: Int) {
    self.id = id
  }
}
