//
//  AnyValue+Operator.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/4.
//

import Foundation

extension AnyValue {
  static func + (left: AnyValue, right: AnyValue) -> AnyValue? {
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
  
  static func - (left: AnyValue, right: AnyValue) -> AnyValue? {
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
  
  static func * (left: AnyValue, right: AnyValue) -> AnyValue? {
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
  
  static func / (left: AnyValue, right: AnyValue) -> AnyValue? {
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
  
  static prefix func - (value: AnyValue) -> AnyValue? {
    switch value {
      case .intValue(let raw):
        return .intValue(raw: -raw)
      case .doubleValue(let raw):
        return .doubleValue(raw: -raw)
      default:
        return nil
    }
  }
  
  static prefix func ! (value: AnyValue) -> AnyValue {
    switch value {
      case .boolValue(let raw):
        return .boolValue(raw: !raw)
      case .nilValue:
        return .boolValue(raw: true)
      default:
        return .boolValue(raw: false)
    }
  }
  
  static func >= (lhs: AnyValue, rhs: AnyValue) -> AnyValue? {
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
  
  static func > (lhs: AnyValue, rhs: AnyValue) -> AnyValue? {
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
  
  static func <= (lhs: AnyValue, rhs: AnyValue) -> AnyValue? {
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
  
  static func < (lhs: AnyValue, rhs: AnyValue) -> AnyValue? {
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
  
  static func === (lhs: AnyValue, rhs: AnyValue) -> AnyValue {
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
  
  static func !== (lhs: AnyValue, rhs: AnyValue) -> AnyValue {
    return !(lhs === rhs)
  }
}

extension AnyValue: Equatable {
  public static func == (lhs: AnyValue, rhs: AnyValue) -> Bool {
    let result = lhs === rhs
    if case .boolValue(true) = result {
      return true
    } else {
      return false
    }
  }
}

extension AnyValue: CustomStringConvertible {
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
