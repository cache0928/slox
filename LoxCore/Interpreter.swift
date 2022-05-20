//
//  Interpreter.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/4.
//

import Foundation

public final class Interpreter  {
  private var environmentStack: [Environment] = [Environment()]
  
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
    try interpret(statements: statements)
  }
  
  func interpret(statements: [Statement]) throws {
    for statement in statements {
      try execute(statement: statement)
    }
  }
  
}

extension Interpreter: StatementExecutor {
  func execute(statement: Statement) throws {
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
        try evaluate(expression: expr)
      case .print(let expr):
        let value = try evaluate(expression: expr)
        Swift.print(value.description)
      case .variableDeclaration(let name, let initializer):
        currentEnvironment.define(variableName: name.lexeme,
                           value: initializer == nil ? .nilValue : try evaluate(expression: initializer!))
      case .block(let statements):
        try executeBlock(statements: statements)
      case .ifStatement(let condition, let thenBranch, let elseBranch):
        let conditionResult = try evaluate(expression: condition)
        if conditionResult.isTruthy {
          try execute(statement: thenBranch)
        } else {
          if let elseBranch = elseBranch {
            try execute(statement: elseBranch)
          }
        }
      case .whileStatement(let condition, let body):
        while try evaluate(expression: condition).isTruthy {
          try execute(statement: body)
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
            try execute(statement: body)
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
        let value = try evaluate(expression: expr)
        throw ReturnValue.value(value)
    }
  }

}

extension Interpreter: ExpressionEvaluator {
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
        return try currentEnvironment.get(variable: varName)
      case .assign(let varName, let valueExpression):
        let value = try evaluate(expression: valueExpression)
        try currentEnvironment.assign(variable: varName, value: value)
        return value
      case .logical(let left, let op, let right):
        let leftResult = try evaluate(expression: left)
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
        return .boolValue(raw: try evaluate(expression: right).isTruthy)
      case .call(let callee, let arguments, let paren):
        guard let callable = try evaluate(expression: callee).callable else {
          throw RuntimeError.invalidCallable(token: paren)
        }
        guard callable.arity == arguments.count else {
          throw RuntimeError.unexceptArgumentsCount(token: paren, expect: callable.arity, got: arguments.count)
        }
        let callArgs = try arguments.map { try evaluate(expression: $0) }
        return try callable.dynamicallyCall(withArguments: callArgs)
    }
  }
}


