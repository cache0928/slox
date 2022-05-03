//
//  Parser.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/2.
//

import Foundation

public struct Parser {
  private let tokens: [Token]
  private var current = 0
  
  public init(tokens: [Token]) {
    self.tokens = tokens
  }
  
  mutating func parse() -> Expression? {
    do {
      return try expression()
    } catch {
      return nil
    }
  }
  
  private mutating func expression() throws -> Expression {
    return try equality()
  }
  
  // 等式表达式
  // comparison ( ( "!=" | "==" ) comparison )*
  private mutating func equality() throws -> Expression {
    var expr = try comparsion()
    while match(types: .BANG_EQUAL, .EQUAL_EQUAL) {
      let op = previousToken!
      let right = try comparsion()
      expr = .binary(left: expr, right: right, op: op)
    }
    return expr
  }
  
  // 比较表达式
  // term ( ( ">" | ">=" | "<" | "<=" ) term )*
  private mutating func comparsion() throws -> Expression {
    var expr = try term()
    while match(types: .GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) {
      let op = previousToken!
      let right = try term()
      expr = .binary(left: expr, right: right, op: op)
    }
    return expr
  }
  
  // 加减法表达式
  // factor ( ( "-" | "+" ) factor )*
  private mutating func term() throws -> Expression {
    var expr = try factor()
    while match(types: .MINUS, .PLUS) {
      let op = previousToken!
      let right = try factor()
      expr = .binary(left: expr, right: right, op: op)
    }
    return expr
  }
  
  // 乘除法表达式
  // unary ( ( "/" | "*" ) unary )*
  private mutating func factor() throws -> Expression {
    var expr = try unary()
    while match(types: .SLASH, .STAR) {
      let op = previousToken!
      let right = try unary()
      expr = .binary(left: expr, right: right, op: op)
    }
    return expr
  }
  
  // 一元表达式
  // ( "!" | "-" ) unary | primary
  private mutating func unary() throws -> Expression {
    if match(types: .BANG, .MINUS) {
      let op = previousToken!
      let right = try unary()
      return .unary(op: op, right: right)
    }
    return try primary()
  }
  
  // 主表达式
  // NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")"
  private mutating func primary() throws -> Expression {
    if match(types: .FALSE) {
      return .literal(value: false)
    }
    if match(types: .TRUE) {
      return .literal(value: true)
    }
    if match(types: .NIL) {
      return .literal(value: nil)
    }
    if match(types: .DOUBLE, .STRING, .INT) {
      return .literal(value: previousToken?.literal)
    }
    if match(types: .LEFT_PAREN) {
      let expr = try expression()
      guard check(type: .RIGHT_PAREN) else {
        throw ParseError.expectParen(token: currentToken!)
      }
      return .grouping(expression: expr)
    }
    throw ParseError.expectExpression(token: currentToken!)
  }
  
  private mutating func synchronize() {
    advanceIndex()
    while !isAtEnd {
      if previousToken?.type == .SEMICOLON {
        return
      }
      switch currentToken?.type {
        case .CLASS, .FUN, .VAR, .FOR, .IF, .WHILE, .PRINT, .RETURN:
          return
        default:
          advanceIndex()
      }
    }
  }
  
  // 当前指向的token是否满足types中的任意一个，如果满足则指针前进并返回true
  private mutating func match(types: TokenType...) -> Bool {
    for type in types {
      if check(type: type) {
        advanceIndex()
        return true
      }
    }
    return false
  }
  
  private func check(type: TokenType) -> Bool {
    guard !isAtEnd else {
      return false
    }
    return currentToken?.type == type
  }
  
  private var isAtEnd: Bool {
    return current >= tokens.count
  }
  
  private var currentToken: Token? {
    guard !isAtEnd else {
      return nil
    }
    return tokens[current]
  }
  
  private var previousToken: Token? {
    guard current > 0 else {
      return nil
    }
    return tokens[current - 1]
  }
  
  @discardableResult
  private mutating func advanceIndex() -> Token? {
    guard !isAtEnd else {
      return nil
    }
    defer {
      current += 1
    }
    return tokens[current]
  }
}
