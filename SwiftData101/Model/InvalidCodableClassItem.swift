//
//  CodableClassItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/20.
//

import Foundation
import SwiftData

@Model
final class InvalidCodableClassItem {
  
  // `Schema([CodableClassItem.self])`
  // Fatal error: Unexpected type for CompositeAttribute: NestedClass
  var nestedClass: NestedClass
  
  init(nestedClass: NestedClass) {
    self.nestedClass = nestedClass
  }
}

final class NestedClass: Codable {
  
  var string: String
  
  init(string: String) {
    self.string = string
  }
}
