//
//  OptionalItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/18.
//

import Foundation
import SwiftData

@Model
final class OptionalItem {
  
  var string: String?
  var int: Int?
  var double: Double?
  var decimal: Decimal?
  var bool: Bool?
  var date: Date?
  var data: Data?
  var uuid: UUID?
  var strings: [String]?
  var ints: [Int]?
  var optionalStrings: [String?]
  var optionalInts: [Int?]
  
  init(string: String? = nil, int: Int? = nil, double: Double? = nil, decimal: Decimal? = nil, bool: Bool? = nil, date: Date? = nil, data: Data? = nil, uuid: UUID? = nil, strings: [String]? = nil, ints: [Int]? = nil, optionalStrings: [String?], optionalInts: [Int?]) {
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
    self.optionalStrings = optionalStrings
    self.optionalInts = optionalInts
  }
}
