//
//  Resolver.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/21.
//

import Foundation
import OrderedCollections

fileprivate class Scope {
  private var inner: [String: Bool] = [:]
  subscript(key: String) -> Bool? {
    get {
      return inner[key]
    }
    set {
      inner[key] = newValue
    }
  }
  
  func contains(key: String) -> Bool {
    return inner.keys.contains(key)
  }
}

/// 执行的是一次简单的语义分析，找出嵌套在各级Block中的赋值语句和变量表达式操作的目标变量定义所在的作用域和当前block的嵌套层数（即距离）并记录
/// 默认没找到的话全部认为是全局变量
/// 使得Interpreter在执行这类语句或者表达式式时无需追溯enviroment队列而直接根据距离去寻找对应的目标变量或者直接试图从全局environment中寻找
/// 另外还分析了一下非function下的return和在非全局下的block中重复定义变量
public final class Resolver {
  enum FunctionType {
    case function
    case none
  }
  
  private var scopes: [Scope] = []
  private var currentFunction = FunctionType.none
  private var bindings: OrderedDictionary<Expression, Int> = [:]
  
  public func resolve(statements: [Statement]) throws -> OrderedDictionary<Expression, Int>  {
    bindings = [:]
    for statement in statements {
      try visit(statement: statement)
    }
    return bindings
  }
}

extension Resolver: ExpressionVisitor {
  func visit(expression: Expression) throws {
    // 只有读取变量表达式和赋值变量表达式时才需要进行resolve
    func resolve(expression: Expression, localVariableName: Token) {
      for (index, scope) in scopes.reversed().enumerated() {
        guard scope.contains(key: localVariableName.lexeme) else {
          continue
        }
        bindings[expression] = index
        return
      }
      /// 如果穷尽scopes也没找到同名变量，则默认其是程序全局变量，不设置distance
      /// 默认其是全局变量
    }
    switch expression {
      case .variable(_, let name):
        // 不支持类似于var a = a;这样的操作
        guard scopes.isEmpty || scopes.last?[name.lexeme] != false else {
          throw ResolvingError.undefinedVariable(token: name)
        }
        resolve(expression: expression, localVariableName: name)
      case .assign(_, let name, let value):
        try visit(expression: value)
        resolve(expression: expression, localVariableName: name)
      case .binary(_, let left, let right, _):
        try visit(expression: left)
        try visit(expression: right)
      case .call(_, let callee, let arguments, _):
        try visit(expression: callee)
        for argument in arguments {
          try visit(expression: argument)
        }
      case .grouping(_, let expression):
        try visit(expression: expression)
      case .literal(_, _):
        return
      case .logical(_, let left, _, let right):
        try visit(expression: left)
        try visit(expression: right)
      case .unary(_, _, let right):
        try visit(expression: right)
    }
  }
}

extension Resolver: StatementVisitor {
  func visit(statement: Statement) throws {
    switch statement {
      case .block(let statements):
        scopes.append(Scope())
        defer {
          _ = scopes.popLast()
        }
        for statement in statements {
          try visit(statement: statement)
        }
      case .variableDeclaration(let name, let initializer):
        guard scopes.last?.contains(key: name.lexeme) != true else {
          throw ResolvingError.variableRedeclaration(token: name)
        }
        scopes.last?[name.lexeme] = false
        if let expr = initializer {
          try visit(expression: expr)
        }
        scopes.last?[name.lexeme] = true
      case .functionDeclaration(let name, let params, let body):
        scopes.last?[name.lexeme] = true
        scopes.append(Scope())
        let from = currentFunction
        currentFunction = .function
        defer {
          _ = scopes.popLast()
          currentFunction = from
        }
        for param in params {
          scopes.last?[param.lexeme] = true
        }
        try visit(statement: body)
      case .expression(let expr):
        try visit(expression: expr)
      case .ifStatement(let condition, let then, let `else`):
        try visit(expression: condition)
        try visit(statement: then)
        if let `else` = `else` {
          try visit(statement: `else`)
        }
      case .print(let expr):
        try visit(expression: expr)
      case .returnStatement(let keyword, let value):
        // 不能在非funciton的环境下return
        guard currentFunction == .function else {
          throw ResolvingError.invalidReturn(token: keyword, message: "Can't return from top-level code.")
        }
        guard let value = value else {
          return
        }
        try visit(expression: value)
      case .whileStatement(let condition, let body):
        try visit(expression: condition)
        try visit(statement: body)
    }
  }
}
