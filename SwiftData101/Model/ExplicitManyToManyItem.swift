//
//  ExplicitManyToManyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/27.
//

import Foundation
import SwiftData

@Model
final class ExplicitManyToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  @Relationship(inverse: \ChildExplicitManyToManyItem.parents)
  var children: [ChildExplicitManyToManyItem] = []
  
  init(id: Int, children: [ChildExplicitManyToManyItem] = []) {
    self.id = id
    self.children = children
  }
}

@Model
final class ChildExplicitManyToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parents: [ExplicitManyToManyItem] = []
  
  init(id: Int, parents: [ExplicitManyToManyItem] = []) {
    self.id = id
    self.parents = parents
  }
}
