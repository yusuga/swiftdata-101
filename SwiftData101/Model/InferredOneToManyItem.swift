//
//  InferredOneToManyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/25.
//

import Foundation
import SwiftData

@Model
final class InferredOneToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var children: [ChildInferredOneToManyItem] = []
  
  init(id: Int, children: [ChildInferredOneToManyItem] = []) {
    self.id = id
    self.children = children
  }
}

@Model
final class ChildInferredOneToManyItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: InferredOneToManyItem?
  
  init(id: Int) {
    self.id = id
  }
}
