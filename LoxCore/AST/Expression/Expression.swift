//
//  Expr.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/4/29.
//

import Foundation
public indirect enum Expression {
  case binary(key: UUID = UUID(), left: Expression, right: Expression, op: Token)
  case grouping(key: UUID = UUID(), expression: Expression)
  case literal(key: UUID = UUID(), value: (any AnyLiteral)?)
  case unary(key: UUID = UUID(), op: Token, right: Expression)
  case variable(key: UUID = UUID(), name: Token)
  case assign(key: UUID = UUID(), name: Token, value: Expression)
  case logical(key: UUID = UUID(), left: Expression, op: Token, right: Expression)
  case call(key: UUID = UUID(), callee: Expression, arguments: [Expression], rightParen: Token)
}

extension Expression: CustomStringConvertible {
  public var description: String {
    switch self {
      case .binary(_, let left, let right, let op):
        return "(\(op.lexeme) \(left.description) \(right.description))"
      case .grouping(_, let expression):
        return "(group \(expression.description))"
      case .literal(_, let value):
        return (value?.description ?? "nil")
      case .unary(_, let op, let right):
        return "(\(op.lexeme) \(right.description))"
      case .variable(_, let name):
        return "(variable \(name.lexeme))"
      case .assign(_, let name, let value):
        return "(assign \(value.description) to \(name.lexeme))"
      case .logical(_, let left, let op, let right):
        return "(\(op.lexeme) \(left.description) \(right.description))"
      case .call(_, let callee, let arguments, _):
        return "(call \(callee.description) with [\(arguments.map {$0.description}.joined(separator: ", "))])"
    }
  }
}

extension Expression: Hashable {
  public static func == (lhs: Expression, rhs: Expression) -> Bool {
    switch (lhs, rhs) {
      case (.binary(let leftKey, _, _, _), .binary(let rightKey, _, _, _)):
        return leftKey == rightKey
      case (.grouping(let leftKey, _), .grouping(let rightKey, _)):
        return leftKey == rightKey
      case (.literal(let leftKey, _), .literal(let rightKey, _)):
        return leftKey == rightKey
      case (.unary(let leftKey, _, _), .unary(let rightKey, _, _)):
        return leftKey == rightKey
      case (.variable(let leftKey, _), .variable(let rightKey, _)):
        return leftKey == rightKey
      case (.assign(let leftKey, _, _), .assign(let rightKey, _, _)):
        return leftKey == rightKey
      case (.logical(let leftKey, _, _, _), .logical(let rightKey, _, _, _)):
        return leftKey == rightKey
      case (.call(let leftKey, _, _, _), .call(let rightKey, _, _, _)):
        return leftKey == rightKey
      default: return false
    }
  }
  
  public func hash(into hasher: inout Hasher) {
    switch self {
      case .binary(let key, _, _, _):
        hasher.combine(key)
      case .grouping(let key, _):
        hasher.combine(key)
      case .literal(let key, _):
        hasher.combine(key)
      case .unary(let key, _, _):
        hasher.combine(key)
      case .variable(let key, _):
        hasher.combine(key)
      case .assign(let key, _, _):
        hasher.combine(key)
      case .logical(let key, _, _, _):
        hasher.combine(key)
      case .call(let key, _, _, _):
        hasher.combine(key)
    }
  }
}
