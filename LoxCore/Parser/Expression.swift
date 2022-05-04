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
}
