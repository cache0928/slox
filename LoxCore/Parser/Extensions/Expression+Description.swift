//
//  Expression+Description.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/1.
//

import Foundation

extension Expression: CustomStringConvertible {
  var description: String {
    switch self {
      case .binary(let left, let right, let op):
        return "(\(op.lexeme) \(left.description) \(right.description))"
      case .grouping(let expression):
        return "(group \(expression.description))"
      case .literal(let value):
        return (value?.description ?? "nil")
      case .unary(let op, let right):
        return "(\(op.lexeme) \(right.description))"
    }
  }
}
