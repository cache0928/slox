//
//  Interpreter.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/4.
//

import Foundation

public struct Interpreter  {
  private let environment: Environment = Environment()
  
  public func interpret(statements: [Statement]) throws {
    for statement in statements {
      try executed(statement: statement)
    }
  }
  
}

extension Interpreter: StatementExecutor {
  func executed(statement: Statement) throws {
    switch statement {
      case .expression(let expr):
        try evaluate(expression: expr)
      case .print(let expr):
        let value = try evaluate(expression: expr)
        Swift.print(value.description)
      case .variable(let name, let initializer):
        environment.define(variable: name,
                           value: initializer == nil ? .nilValue : try evaluate(expression: initializer!))
    }
  }
  
  @discardableResult
  func evaluate(expression: Expression) throws -> ExpressionValue {
    switch expression {
      case .literal(let value):
        guard value != nil else {
          return ExpressionValue.nilValue
        }
        if let intValue = value as? Int {
          return ExpressionValue.intValue(raw: intValue)
        } else if let doubleValue = value as? Double {
          return ExpressionValue.doubleValue(raw: doubleValue)
        } else if let strValue = value as? String {
          return ExpressionValue.stringValue(raw: strValue)
        }
        return ExpressionValue.boolValue(raw: value as! Bool)
      case .grouping(let expression):
        return try evaluate(expression: expression)
      case .unary(let op, let right):
        return try evaluateUnary(op: op, right: right)
      case .binary(let left, let right, let op):
        return try evaluateBinary(op: op, left: left, right: right)
      case .variable(let varName):
        return try environment[varName]
      case .assign(let varName, let valueExpression):
        let value = try evaluate(expression: valueExpression)
        try environment.redefine(variable: varName, value: value)
        return value
    }
  }
}


