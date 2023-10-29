//
//  TransientItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/11/04.
//

import Foundation
import SwiftData

@Model
final class TransientItem {
  
  var value: Int
  
  @Transient
  var ignoreValue: Int = 0 // デフォルト値が必須
  
  init(value: Int) {
    self.value = value
  }
}
