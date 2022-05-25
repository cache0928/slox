//
//  Interpreter.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/4.
//

import Foundation
import OrderedCollections

public final class Interpreter  {
  private var environmentStack: [Environment] = [Environment()]
  // 读取变量表达式和赋值表达式涉及的变量所在的environment距离当前environment的距离
  private var bindings: OrderedDictionary<Expression, Int> = [:]
  
  private var globalEnvironment: Environment {
    return environmentStack.first!
  }
  
  private var currentEnvironment: Environment {
    return environmentStack.last!
  }
  
  public init() {
    // 定义一些native function
    self.globalEnvironment.define(
      variableName: "clock",
      value: .anyValue(raw: AnyCallable(arity: 0) { _ in
        return .doubleValue(raw: Date().timeIntervalSince1970)
      })
    )
  }
  
  public func interpret(code: String) throws {
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try scanner.scanTokens())
    let statements = try parser.parse()
    let resolver = Resolver()
    bindings = try resolver.resolve(statements: statements)
    try interpret(statements: statements)
  }
  
  private func interpret(statements: [Statement]) throws {
    for statement in statements {
      try visit(statement: statement)
    }
  }
}

extension Interpreter: StatementVisitor {
  func visit(statement: Statement) throws {
    func executeBlock(statements: [Statement]) throws {
      let environment = Environment(enclosing: currentEnvironment)
      environmentStack.append(environment)
      defer {
        _ = environmentStack.popLast()
      }
      try interpret(statements: statements)
    }
    switch statement {
      case .expression(let expr):
        try visit(expression: expr)
      case .print(let expr):
        let value = try visit(expression: expr)
        Swift.print(value.description)
      case .variableDeclaration(let name, let initializer):
        currentEnvironment.define(variableName: name.lexeme,
                           value: initializer == nil ? .nilValue : try visit(expression: initializer!))
      case .block(let statements):
        try executeBlock(statements: statements)
      case .ifStatement(let condition, let thenBranch, let elseBranch):
        let conditionResult = try visit(expression: condition)
        if conditionResult.isTruthy {
          try visit(statement: thenBranch)
        } else {
          if let elseBranch = elseBranch {
            try visit(statement: elseBranch)
          }
        }
      case .whileStatement(let condition, let body):
        while try visit(expression: condition).isTruthy {
          try visit(statement: body)
        }
      case .functionDeclaration(let name, let params, let body):
        let closure = currentEnvironment
        let function = Function(name: name.lexeme,
                                paramNames: params.map { $0.lexeme },
                                closure: closure) {
          [unowned self] args in
          // 复原function定义时候的环境栈，这样可以使local functions能访问捕获到的定义时候的变量，否则这些变量会随着定义时候environment的pop而消失
          // 将function的环境插入到当前的环境栈中，由此可以从函数的形参名获取实参值
          let callStack = Environment(enclosing: closure)
          environmentStack.append(callStack)
          // 给形参赋值
          for paramEntry in zip(params, args) {
            callStack.define(variableName: paramEntry.0.lexeme, value: paramEntry.1)
          }
          defer {
            _ = environmentStack.popLast()
          }
          do {
            try visit(statement: body)
          } catch {
            // 处理return的结果
            guard let returnValue = error as? ReturnValue else {
              throw error
            }
            switch returnValue {
              case .value(let value):
                return value
            }
          }
          return ExpressionValue.anyValue(raw: ())
        }
        currentEnvironment.define(variableName: name.lexeme, value: .anyValue(raw: function))
      case .returnStatement(_, let valueExpr):
        // 这里将lox的return值直接通过异常抛出，然后在try执行block的地方直接catch就等于直接跳出多重调用栈取到返回值
        guard let expr = valueExpr else {
          throw ReturnValue.value()
        }
        let value = try visit(expression: expr)
        throw ReturnValue.value(value)
      case .classStatement(let name, let methods):
        let loxClass = Class(name: name.lexeme)
        currentEnvironment.define(variableName: name.lexeme, value: .anyValue(raw: loxClass))
    }
  }

}

extension Interpreter: ExpressionVisitor {
  @discardableResult
  func visit(expression: Expression) throws -> ExpressionValue {
    switch expression {
      case .literal(_, let value):
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
      case .grouping(_, let expression):
        return try visit(expression: expression)
      case .unary(_, let op, let right):
        return try evaluateUnary(op: op, right: right)
      case .binary(_, let left, let right, let op):
        return try evaluateBinary(op: op, left: left, right: right)
      case .variable(_, let varName):
        // resolver处理之后，没有distance的话默认在global中
        guard let distance = bindings[expression] else {
          return try globalEnvironment.get(variable: varName)
        }
        return try currentEnvironment.get(variable: varName, at: distance)
      case .assign(_, let varName, let valueExpression):
        let value = try visit(expression: valueExpression)
        guard let distance = bindings[expression] else {
          try globalEnvironment.assign(variable: varName, value: value)
          return value
        }
        try currentEnvironment.assign(variable: varName, value: value, at: distance)
        return value
      case .logical(_, let left, let op, let right):
        let leftResult = try visit(expression: left)
        switch op.type {
          case .OR:
            if leftResult.isTruthy {
              return .boolValue(raw: true)
            }
          default:
            if !leftResult.isTruthy {
              return .boolValue(raw: false)
            }
        }
        return .boolValue(raw: try visit(expression: right).isTruthy)
      case .call(_, let callee, let arguments, let paren):
        guard let callable = try visit(expression: callee).callable else {
          throw RuntimeError.invalidCallable(token: paren)
        }
        guard callable.arity == arguments.count else {
          throw RuntimeError.unexceptArgumentsCount(token: paren, expect: callable.arity, got: arguments.count)
        }
        let callArgs = try arguments.map { try visit(expression: $0) }
        return try callable.dynamicallyCall(withArguments: callArgs)
      case .getter(_, let object, let propertyName):
        let value = try visit(expression: object)
        guard case let .anyValue(raw) = value,
              let instance = raw as? Instance else {
          throw RuntimeError.operandError(token: propertyName, message: "Only instances have properties.")
        }
        guard let property = instance[dynamicMember: propertyName.lexeme] else {
          throw RuntimeError.undefinedProperty(token: propertyName)
        }
        return property
      case .setter(_, let object, let propertyName, let value):
        let object = try visit(expression: object)
        guard case let .anyValue(raw) = object,
              let instance = raw as? Instance else {
          throw RuntimeError.operandError(token: propertyName, message: "Only instances have properties.")
        }
        let value = try visit(expression: value)
        instance[dynamicMember: propertyName.lexeme] = value
        return value
    }
  }
  
  func evaluateUnary(op: Token, right: Expression) throws -> ExpressionValue {
    let rightValue = try visit(expression: right)
    switch op.type {
      case .MINUS:
        guard let result = -rightValue else {
          throw RuntimeError.operandError(token: op, message: "Operand must be a number.")
        }
        return result
      case .BANG:
        return !rightValue
      default:
        throw RuntimeError.operandError(token: op, message: "Unsupport unary operator.")
    }
  }
  
  func evaluateBinary(op: Token, left: Expression, right: Expression) throws -> ExpressionValue {
    func evaluateOp(leftValue: ExpressionValue,
                    rightValue: ExpressionValue,
                    `operator`: (ExpressionValue, ExpressionValue) -> ExpressionValue?) throws -> ExpressionValue  {
      guard let result = `operator`(leftValue, rightValue) else {
        throw RuntimeError.operandError(
          token: op,
          message: op.type == .PLUS ? "Operands must be two numbers or two strings." : "Operands must be two numbers."
        )
      }
      return result
    }
    
    let leftValue = try visit(expression: left)
    let rightValue = try visit(expression: right)
    switch op.type {
      case .PLUS:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: +)
      case .MINUS:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: -)
      case .STAR:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: *)
      case .SLASH:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: /)
      case .GREATER:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: >)
      case .GREATER_EQUAL:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: >=)
      case .LESS:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: <)
      case .LESS_EQUAL:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: <=)
      case .EQUAL_EQUAL:
        return leftValue === rightValue
      case .BANG_EQUAL:
        return leftValue !== rightValue
      default:
        throw RuntimeError.operandError(token: op, message: "Unsupport binary operator.")
    }
  }
}


