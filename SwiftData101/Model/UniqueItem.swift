//
//  UniqueItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/20.
//

import Foundation
import SwiftData

@Model
final class UniqueItem {
  
  @Attribute(.unique) var id: Int
  var value: String
  
  init(id: Int, value: String) {
    self.id = id
    self.value = value
  }
}
