//
//  SimpleItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/17.
//

import Foundation
import SwiftData

@Model
final class SimpleItem {
  
  var value: Int
  
  init(value: Int) {
    self.value = value
  }
}
