//
//  Expr.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/4/29.
//

import Foundation

public indirect enum Expression {
  case binary(left: Expression, right: Expression, op: Token)
  case grouping(expression: Expression)
  case literal(value: (any AnyLiteral)?)
  case unary(op: Token, right: Expression)
  case variable(name: Token)
  case assign(name: Token, value: Expression)
  case logical(left: Expression, op: Token, right: Expression)
  case call(callee: Expression, arguments: [Expression], rightParen: Token)
}

extension Expression: CustomStringConvertible {
  public var description: String {
    switch self {
      case .binary(let left, let right, let op):
        return "(\(op.lexeme) \(left.description) \(right.description))"
      case .grouping(let expression):
        return "(group \(expression.description))"
      case .literal(let value):
        return (value?.description ?? "nil")
      case .unary(let op, let right):
        return "(\(op.lexeme) \(right.description))"
      case .variable(let name):
        return "(variable \(name.lexeme))"
      case .assign(let name, let value):
        return "(assign \(value.description) to \(name.lexeme))"
      case .logical(let left, let op, let right):
        return "(\(op.lexeme) \(left.description) \(right.description))"
      case .call(let callee, let arguments, _):
        return "(call \(callee.description) with [\(arguments.map {$0.description}.joined(separator: ", "))])"
    }
  }
}
