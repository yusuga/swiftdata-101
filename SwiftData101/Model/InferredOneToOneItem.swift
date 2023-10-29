//
//  InferredOneToOneItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/27.
//

import Foundation
import SwiftData

@Model
final class InferredOneToOneItem {
  
  @Attribute(.unique)
  var id: Int
  
  var child: ChildInferredOneToOneItem?
  
  init(id: Int, child: ChildInferredOneToOneItem?) {
    self.id = id
    self.child = child
  }
}

@Model
final class ChildInferredOneToOneItem {
  
  @Attribute(.unique)
  var id: Int
  
  var parent: InferredOneToOneItem?
  
  init(id: Int) {
    self.id = id
  }
}
