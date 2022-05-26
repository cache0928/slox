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
  case getter(key: UUID = UUID(), object: Expression, propertyName: Token)
  case setter(key: UUID = UUID(), object: Expression, propertyName: Token, value: Expression)
  case this(key: UUID = UUID(), keyword: Token)
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
      case .getter(_, let object, let propertyName):
        return "(get \(object).\(propertyName.lexeme))"
      case .setter(_, let object, let propertyName, let value):
        return "(set \(object).\(propertyName.lexeme) = \(value))"
      case .this(_, _):
        return "(this)"
        
    }
  }
}

extension Expression: Hashable {
  private var key: UUID {
    switch self {
      case .binary(let key, _, _, _),
       .grouping(let key, _),
       .literal(let key, _),
       .unary(let key, _, _),
       .variable(let key, _),
       .assign(let key, _, _),
       .logical(let key, _, _, _),
       .call(let key, _, _, _),
       .getter(let key, _, _),
       .setter(let key, _, _, _),
       .this(let key, _):
        return key
    }
  }
  
  public static func == (lhs: Expression, rhs: Expression) -> Bool {
    return lhs.key == rhs.key
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(key)
  }
}
