//
//  EnumItem.swift
//  SwiftData101
//
//  Created by yusuga on 2023/10/18.
//

import Foundation
import SwiftData

@Model
final class EnumItem {
  
  var plain: Enum
  var plains: [Enum]
  var string: EnumString
  var strings: [EnumString]
  var int: EnumInt
  var ints: [EnumInt]
  var associatedValue: EnumAssociatedValue
  var associatedValues: [EnumAssociatedValue]
  var generic: EnumGeneric<String, Int>
  var generics: [EnumGeneric<String, Int>]
  
  var optionalPlain: Enum?

  init(plain: Enum, plains: [Enum], string: EnumString, strings: [EnumString], int: EnumInt, ints: [EnumInt], associatedValue: EnumAssociatedValue, associatedValues: [EnumAssociatedValue], generic: EnumGeneric<String, Int>, generics: [EnumGeneric<String, Int>], optionalPlain: Enum?) {
    self.plain = plain
    self.plains = plains
    self.string = string
    self.strings = strings
    self.int = int
    self.ints = ints
    self.associatedValue = associatedValue
    self.associatedValues = associatedValues
    self.generic = generic
    self.generics = generics
    self.optionalPlain = optionalPlain
  }
}

enum Enum: Codable {
  
  case foo
  case bar
}

enum EnumString: String, Codable {
  
  case foo
  case bar
}

enum EnumInt: Int, Codable {
  
  case foo
  case bar
}

enum EnumAssociatedValue: Codable, Equatable {
  
  case foo(String)
  case bar(String, Int)
  case baz(string: String, int: Int)
  case qux(String?)
}

enum EnumGeneric<T1: Codable & Equatable, T2: Codable & Equatable>: Codable, Equatable {
  
  case foo(T1)
  case bar(T2)
}
