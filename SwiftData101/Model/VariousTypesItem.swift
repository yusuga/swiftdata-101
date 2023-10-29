//
//  VariousTypesItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/18.
//

import Foundation
import SwiftData

@Model
final class VariousTypesItem {
  
  var string: String
  var int: Int
  var double: Double
  var decimal: Decimal
  var bool: Bool
  var date: Date
  var data: Data
  var uuid: UUID
  var strings: [String]
  var ints: [Int]
  
  // - Note: Not supported
  // var uint: UInt
  // var any: Any
  
  init(string: String, int: Int, double: Double, decimal: Decimal, bool: Bool, date: Date, data: Data, uuid: UUID, strings: [String], ints: [Int]) {
    self.string = string
    self.int = int
    self.double = double
    self.decimal = decimal
    self.bool = bool
    self.date = date
    self.data = data
    self.uuid = uuid
    self.strings = strings
    self.ints = ints
  }
}
