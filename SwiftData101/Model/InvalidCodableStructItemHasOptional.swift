//
//  InvalidCodableStructItemHasOptional.swift
//  SwiftData101
//
//  Created by yusuga on 2023/11/04.
//

import Foundation
import SwiftData

@Model
final class InvalidCodableStructItemHasOptionalInt {
  
  var child: ChildInvalidCodableStructItemHasOptionalInt
  
  init(child: ChildInvalidCodableStructItemHasOptionalInt) {
    self.child = child
  }
}

struct ChildInvalidCodableStructItemHasOptionalInt: Codable {
  
  var optionalValue: Int?
}

@Model
final class InvalidCodableStructItemHasOptionalString {
  
  var child: ChildInvalidCodableStructItemHasOptionalString
  
  init(child: ChildInvalidCodableStructItemHasOptionalString) {
    self.child = child
  }
}

struct ChildInvalidCodableStructItemHasOptionalString: Codable {
  
  var optionalValue: String?
}
