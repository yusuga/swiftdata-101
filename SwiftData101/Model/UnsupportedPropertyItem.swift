//
//  UnsupportedPropertyItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/11/05.
//

import Foundation
import SwiftData

@Model
final class UnsupportedPropertyItemHasUInt {
  
  var uint: UInt
  
  init(uint: UInt) {
    self.uint = uint
  }
}

/// コンパイルすると @Model マクロで生成されたコード内で以下のエラーが発生する。
/// ```
/// No exact matches in call to instance method 'getValue'
/// No exact matches in call to instance method 'setValue'
/// ```
#if false
@Model
final class UnsupportedPropertyItemHasAny {
  
  var any: Any
  
  init(any: Any) {
    self.any = any
  }
}
#endif
