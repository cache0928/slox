//
//  Interpreter.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/4.
//

import Foundation

public struct Interpreter {
  public init() {}
  
  public func interpret(expression: Expression) throws -> AnyValue {
    return try expression.evaluated
  }
}
