//
//  InvalidInferredManyToManyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/27.
//

import Foundation
import SwiftData

@Model
final class InvalidInferredManyToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var children: [ChildInvalidInferredManyToManyItem] = []
  
  init(id: Int, children: [ChildInvalidInferredManyToManyItem] = []) {
    self.id = id
    self.children = children
  }
}

@Model
final class ChildInvalidInferredManyToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parents: [InvalidInferredManyToManyItem] = []
  
  init(id: Int, parents: [InvalidInferredManyToManyItem] = []) {
    self.id = id
    self.parents = parents
  }
}
