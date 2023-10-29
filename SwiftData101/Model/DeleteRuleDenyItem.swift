//
//  DeleteRuleDenyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/11/05.
//

import Foundation
import SwiftData

@Model
final class DeleteRuleDenyItem {
  
  @Attribute(.unique)
  var id: Int
  
  @Relationship(deleteRule: .deny, inverse: \ChildDeleteRuleDenyItem.parent)
  var children: [ChildDeleteRuleDenyItem] = []
  
  init(id: Int, children: [ChildDeleteRuleDenyItem] = []) {
    self.id = id
    self.children = children
  }
}

@Model
final class ChildDeleteRuleDenyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: DeleteRuleDenyItem?
  
  init(id: Int) {
    self.id = id
  }
}



