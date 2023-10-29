//
//  ExplicitOneToManyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/27.
//

import Foundation
import SwiftData

@Model
final class ExplicitOneToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  @Relationship(inverse: \ChildExplicitOneToManyItem.parent)
  var children: [ChildExplicitOneToManyItem] = []
  
  init(id: Int, children: [ChildExplicitOneToManyItem] = []) {
    self.id = id
    self.children = children
  }
}

@Model
final class ChildExplicitOneToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: ExplicitOneToManyItem?
  
  init(id: Int) {
    self.id = id
  }
}
