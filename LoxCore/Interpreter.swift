//
//  Interpreter.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/4.
//

import Foundation

public final class Interpreter  {
  private var environmentStack: [Environment] = [Environment()]
  
  public init() {
    
  }
  
  public func interpret(code: String) throws {
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try scanner.scanTokens())
    let statements = parser.parse()
    try interpret(statements: statements)
  }
  
  func interpret(statements: [Statement]) throws {
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
      case .variableDeclaration(let name, let initializer):
        environmentStack.last?.define(variable: name,
                           value: initializer == nil ? .nilValue : try evaluate(expression: initializer!))
      case .block(let statements):
        try executeBlock(statements: statements)
    }
  }
  
  private func executeBlock(statements: [Statement]) throws {
    let environment = Environment(enclosing: self.environmentStack.last)
    environmentStack.append(environment)
    defer {
      _ = environmentStack.popLast()
    }
    try interpret(statements: statements)
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
        return try environmentStack.last![varName]
      case .assign(let varName, let valueExpression):
        let value = try evaluate(expression: valueExpression)
        try environmentStack.last?.assign(variable: varName, value: value)
        return value
    }
  }
}


