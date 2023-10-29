//
//  ExplicitOneToOneItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/25.
//

import Foundation
import SwiftData

@Model
final class ExplicitOneToOneItem {
  
  @Attribute(.unique) 
  var id: Int
  
  @Relationship(inverse: \ChildExplicitOneToOneItem.parent) 
  var child: ChildExplicitOneToOneItem?
  
  init(id: Int, child: ChildExplicitOneToOneItem?) {
    self.id = id
    self.child = child
  }
}
  
@Model
final class ChildExplicitOneToOneItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: ExplicitOneToOneItem?
  
  init(id: Int) {
    self.id = id
  }
}
