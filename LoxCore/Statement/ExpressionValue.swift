//
//  LoxValue.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/3.
//

import Foundation

public enum ExpressionValue {
  case nilValue
  case boolValue(raw: Bool)
  case intValue(raw: Int)
  case doubleValue(raw: Double)
  case stringValue(raw: String)
  case anyValue(raw: Any)
}

extension ExpressionValue: CustomStringConvertible {
  public var description: String {
    switch self {
      case .nilValue: return "nil"
      case .intValue(let raw): return raw.description
      case .boolValue(let raw): return raw.description
      case .doubleValue(let raw): return raw.description
      case .stringValue(let raw): return raw
      case .anyValue(let raw): return "\(raw)"
    }
  }
}

extension ExpressionValue: RawRepresentable {
  public init(rawValue: Any?) {
    guard let raw = rawValue else {
      self = .nilValue
      return
    }
    if let boolValue = raw as? Bool {
      self = .boolValue(raw: boolValue)
    } else if let intValue = raw as? Int {
      self = .intValue(raw: intValue)
    } else if let doubleValue = raw as? Double {
      self = .doubleValue(raw: doubleValue)
    } else if let stringValue = raw as? String {
      self = .stringValue(raw: stringValue)
    } else {
      self = .anyValue(raw: raw)
    }
  }
  
  public var rawValue: Any? {
    switch self {
      case .nilValue:
        return nil
      case .intValue(let raw):
        return raw
      case .boolValue(let raw):
        return raw
      case .doubleValue(let raw):
        return raw
      case .stringValue(let raw):
        return raw
      case .anyValue(let raw):
        return raw
    }
  }
}

extension ExpressionValue: ExpressibleByIntegerLiteral {
  public init(integerLiteral value: IntegerLiteralType) {
    self = ExpressionValue(rawValue: value)
  }
}

extension ExpressionValue: ExpressibleByNilLiteral {
  public init(nilLiteral: ()) {
    self = ExpressionValue(rawValue: nil)
  }
}

extension ExpressionValue: ExpressibleByFloatLiteral {
  public init(floatLiteral value: FloatLiteralType) {
    self = ExpressionValue(rawValue: value)
  }
}

extension ExpressionValue: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: BooleanLiteralType) {
    self = ExpressionValue(rawValue: value)
  }
}

extension ExpressionValue: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self = ExpressionValue(rawValue: value)
  }
}

extension ExpressionValue {
  var isTruthy: Bool {
    switch self {
      case .boolValue(let raw):
        return raw
      case .nilValue:
        return false
      default:
        return true
    }
  }
  
  static func + (left: ExpressionValue, right: ExpressionValue) -> ExpressionValue? {
    switch (left, right) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .intValue(raw: leftRaw + rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .doubleValue(raw: leftRaw + rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .doubleValue(raw: leftRaw + Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .doubleValue(raw: rightRaw + Double(leftRaw))
      case (.stringValue(let leftRaw), .stringValue(let rightRaw)):
        return .stringValue(raw: leftRaw + rightRaw)
      default:
        return nil
    }
  }
  
  static func - (left: ExpressionValue, right: ExpressionValue) -> ExpressionValue? {
    switch (left, right) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .intValue(raw: leftRaw - rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .doubleValue(raw: leftRaw - rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .doubleValue(raw: leftRaw - Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .doubleValue(raw: Double(leftRaw) - rightRaw)
      default:
        return nil
    }
  }
  
  static func * (left: ExpressionValue, right: ExpressionValue) -> ExpressionValue? {
    switch (left, right) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .intValue(raw: leftRaw * rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .doubleValue(raw: leftRaw * rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .doubleValue(raw: leftRaw * Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .doubleValue(raw: rightRaw * Double(leftRaw))
      default:
        return nil
    }
  }
  
  static func / (left: ExpressionValue, right: ExpressionValue) -> ExpressionValue? {
    switch (left, right) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .intValue(raw: leftRaw / rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .doubleValue(raw: leftRaw / rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .doubleValue(raw: leftRaw / Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .doubleValue(raw: Double(leftRaw) / rightRaw)
      default:
        return nil
    }
  }
  
  static prefix func - (value: ExpressionValue) -> ExpressionValue? {
    switch value {
      case .intValue(let raw):
        return .intValue(raw: -raw)
      case .doubleValue(let raw):
        return .doubleValue(raw: -raw)
      default:
        return nil
    }
  }
  
  static prefix func ! (value: ExpressionValue) -> ExpressionValue {
    return .boolValue(raw: !value.isTruthy)
  }
  
  static func >= (lhs: ExpressionValue, rhs: ExpressionValue) -> ExpressionValue? {
    switch (lhs, rhs) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw >= rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: leftRaw >= rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw >= Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: Double(leftRaw) >= rightRaw)
      default:
        return nil
    }
  }
  
  static func > (lhs: ExpressionValue, rhs: ExpressionValue) -> ExpressionValue? {
    switch (lhs, rhs) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw > rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: leftRaw > rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw > Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: Double(leftRaw) > rightRaw)
      default:
        return nil
    }
  }
  
  static func <= (lhs: ExpressionValue, rhs: ExpressionValue) -> ExpressionValue? {
    switch (lhs, rhs) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw <= rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: leftRaw <= rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw <= Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: Double(leftRaw) <= rightRaw)
      default:
        return nil
    }
  }
  
  static func < (lhs: ExpressionValue, rhs: ExpressionValue) -> ExpressionValue? {
    switch (lhs, rhs) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw < rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: leftRaw < rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw < Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: Double(leftRaw) < rightRaw)
      default:
        return nil
    }
  }
  
  static func === (lhs: ExpressionValue, rhs: ExpressionValue) -> ExpressionValue {
    switch (lhs, rhs) {
      case (.intValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw == rightRaw)
      case (.doubleValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: leftRaw == rightRaw)
      case (.doubleValue(let leftRaw), .intValue(let rightRaw)):
        return .boolValue(raw: leftRaw == Double(rightRaw))
      case (.intValue(let leftRaw), .doubleValue(let rightRaw)):
        return .boolValue(raw: rightRaw == Double(leftRaw))
      case (.stringValue(let leftRaw), .stringValue(let rightRaw)):
        return .boolValue(raw: leftRaw == rightRaw)
      case (.boolValue(let leftRaw), .boolValue(let rightRaw)):
        return .boolValue(raw: leftRaw == rightRaw)
      case (.nilValue, .nilValue):
        return .boolValue(raw: true)
      default:
        return .boolValue(raw: false)
    }
  }
  
  static func !== (lhs: ExpressionValue, rhs: ExpressionValue) -> ExpressionValue {
    return !(lhs === rhs)
  }
}

extension ExpressionValue: Equatable {
  public static func == (lhs: ExpressionValue, rhs: ExpressionValue) -> Bool {
    let result = lhs === rhs
    if case .boolValue(true) = result {
      return true
    } else {
      return false
    }
  }
}
