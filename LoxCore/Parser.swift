//
//  Parser.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/2.
//

import Foundation

struct Parser {
  private let tokens: [Token]
  private var currentParseIndex = 0
  
  init(tokens: [Token]) {
    self.tokens = tokens
  }
  
  mutating func parse() -> [Statement] {
    var statements: [Statement] = []
    while !isAtEnd {
      do {
        statements.append(try statement())
      } catch {
        // 此处只有ParseError
        // 语法错误，进入错误恢复模式
        synchronize()
        continue
      }
    }
    return statements
  }
  
  // MARK: - 解析语句
  
  mutating func statement() throws -> Statement {
    if match(types: .VAR) {
      return try declarationStatement()
    }
    if match(types: .PRINT) {
      return try printStatement()
    }
    if match(types: .LEFT_BRACE) {
      return .block(statements: try blockStatement())
    }
    if match(types: .IF) {
      return try ifStatement()
    }
    return try expressionStatement()
  }
  
  // 变量定义语句
  private mutating func declarationStatement() throws -> Statement {
    let varName = try attemp(consume: .IDENTIFIER, else: ParseError.expectVariableName(token: currentToken))
    var initializer: Expression? = nil
    if match(types: .EQUAL) {
      initializer = try expression()
    }
    try attemp(consume: .SEMICOLON, else: ParseError.expectSemicolon(token: currentToken))
    return .variableDeclaration(name: varName, initializer: initializer)
  }
  
  // 表达式语句
  private mutating func expressionStatement() throws -> Statement {
    let expression = try expression()
    try attemp(consume: .SEMICOLON, else: ParseError.expectSemicolon(token: currentToken))
    return .expression(expression)
  }
  
  // print语句
  private mutating func printStatement() throws -> Statement {
    let expression = try expression()
    try attemp(consume: .SEMICOLON, else: ParseError.expectSemicolon(token: currentToken))
    return .print(expression: expression)
  }
  
  // 作用域块
  private mutating func blockStatement() throws -> [Statement] {
    var statements: [Statement] = []
    while !check(type: .RIGHT_BRACE) && !isAtEnd {
      statements.append(try statement())
    }
    try attemp(consume: .RIGHT_BRACE, else: ParseError.expectRightBrace(token: currentToken))
    return statements
  }
  
  // if块
  private mutating func ifStatement() throws -> Statement {
    try attemp(consume: .LEFT_PAREN, else: ParseError.expectLeftParen(token: currentToken))
    let condition = try expression()
    try attemp(consume: .RIGHT_PAREN, else: ParseError.expectRightParen(token: currentToken))
    let thenBranch = try statement()
    let elseBranch = match(types: .ELSE) ? try statement() : nil
    return .ifStatement(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
  }
  
  // MARK: - 解析表达式
  
  mutating func expression() throws -> Expression {
    return try assignment()
  }
  
  // 赋值表达式
  // IDENTIFIER "=" assignment | equality
  private mutating func assignment() throws -> Expression {
    let expr = try equality()
    if match(types: .EQUAL) {
      let equalToken = previousToken!
      let value = try assignment()
      guard case let Expression.variable(varName) = expr else {
        throw ParseError.invalidAssignmentTarget(token: equalToken)
      }
      return .assign(name: varName, value: value)
    }
    return expr
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
  // NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" | IDENTIFIER 
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
    if match(types: .IDENTIFIER) {
      return .variable(name: previousToken!)
    }
    if match(types: .DOUBLE, .STRING, .INT) {
      return .literal(value: previousToken?.literal)
    }
    if match(types: .LEFT_PAREN) {
      let expr = try expression()
      try attemp(consume: .RIGHT_PAREN, else: ParseError.expectRightParen(token: currentToken))
      return .grouping(expression: expr)
    }
    throw ParseError.expectExpression(token: currentToken)
  }
  
  // MARK: - 工具方法
  
  private mutating func synchronize() {
    advanceIndex()
    while !isAtEnd {
      if previousToken?.type == .SEMICOLON {
        return
      }
      switch currentToken.type {
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
    return currentToken.type == type
  }
  
  @discardableResult
  private mutating func attemp(consume type: TokenType, else throw: Error) throws -> Token {
    guard check(type: type) else {
      throw `throw`
    }
    return advanceIndex()!
  }
  
  private var isAtEnd: Bool {
    // 最后一个token为EOF，指向EOF及以后就算End
    return currentParseIndex >= tokens.count - 1
  }
  
  private var currentToken: Token {
    guard !isAtEnd else {
      return tokens.last!
    }
    return tokens[currentParseIndex]
  }
  
  private var previousToken: Token? {
    guard currentParseIndex > 0 else {
      return nil
    }
    return tokens[currentParseIndex - 1]
  }
  
  @discardableResult
  private mutating func advanceIndex() -> Token? {
    guard !isAtEnd else {
      return nil
    }
    defer {
      currentParseIndex += 1
    }
    return tokens[currentParseIndex]
  }
}
