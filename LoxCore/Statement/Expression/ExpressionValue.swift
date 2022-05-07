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
