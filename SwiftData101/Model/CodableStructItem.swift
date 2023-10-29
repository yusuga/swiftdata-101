//
//  CodableStructItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/19.
//

import Foundation
import SwiftData

@Model
final class CodableStructItem {
  
  var child: ChildCodableStructItem
  
  init(child: ChildCodableStructItem) {
    self.child = child
  }
}
  
struct ChildCodableStructItem: Codable {
  
  var string: String
  var int: Int
  var double: Double
  var decimal: Decimal
  var bool: Bool
  var date: Date
  var data: Data
  var uuid: UUID
  
  var plainEnum: Enum
  var grandchild: GrandchildCodableStructItem
}

struct GrandchildCodableStructItem: Codable {
  
  var value: Int
}
