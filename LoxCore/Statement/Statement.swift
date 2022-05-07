//
//  Statement.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/5.
//

import Foundation

public enum Statement {
  case expression(_: Expression)
  case print(expression: Expression)
}

extension Statement {
  var executed: ExpressionValue? {
    get throws {
      switch self {
        case .expression(let expr):
          return try expr.evaluated
        case .print(let expr):
          let value = try expr.evaluated
          Swift.print(value.description)
          return nil
      }
    }
  }
}
