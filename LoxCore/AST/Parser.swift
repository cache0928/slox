//
//  Parser.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/2.
//

import Foundation

public struct Parser {
  private let tokens: [Token]
  private var currentParseIndex = 0
  
  public init(tokens: [Token]) {
    self.tokens = tokens
  }
  
  public mutating func parse() throws -> [Statement] {
    var statements: [Statement] = []
    while !isAtEnd {
      statements.append(try statement())
    }
    return statements
  }
  
  // MARK: - 解析语句
  
  mutating func statement() throws -> Statement {
    if match(types: .VAR) {
      return try variableDeclarationStatement()
    }
    if match(types: .FUN) {
      return try callableDeclarationStatement(description: "function")
    }
    if match(types: .PRINT) {
      return try printStatement()
    }
    if match(types: .LEFT_BRACE) {
      return try blockStatement()
    }
    if match(types: .IF) {
      return try ifStatement()
    }
    if match(types: .WHILE) {
      return try whileStatement()
    }
    if match(types: .FOR) {
      return try forStatement()
    }
    if match(types: .RETURN) {
      return try returnStatement()
    }
    return try expressionStatement()
  }
  
  /// 变量定义语句
  private mutating func variableDeclarationStatement() throws -> Statement {
    let varName = try attemp(consume: .IDENTIFIER, else: ParseError.expectVariableName(token: currentToken))
    var initializer: Expression? = nil
    if match(types: .EQUAL) {
      initializer = try expression()
    }
    try attemp(consume: .SEMICOLON, else: ParseError.expectSemicolon(token: currentToken))
    return .variableDeclaration(name: varName, initializer: initializer)
  }
  
  /// function定义语句
  private mutating func callableDeclarationStatement(description: String) throws -> Statement {
    // 解析函数名
    let name = try attemp(consume: .IDENTIFIER,
                          else: ParseError.expectVariableName(token: currentToken, message: "Expect \(description) name."))
    try attemp(consume: .LEFT_PAREN, else: ParseError.expectLeftParen(token: currentToken,
                                                                      message: "Expect '(' after \(description) name."))
    // 解析函数参数
    var params: [Token] = []
    if !match(types: .RIGHT_PAREN) {
      repeat {
        if params.count >= 255 {
          throw ParseError.tooManyArguments(token: currentToken, message: "Can't have more than 255 parameters.")
        }
        params.append(try attemp(consume: .IDENTIFIER, else: ParseError.expectVariableName(token: currentToken,
                                                                                           message: "Expect parameter name.")))
      } while match(types: .COMMA)
      try attemp(consume: .RIGHT_PAREN, else: ParseError.expectRightParen(token: currentToken,
                                                                          message: "Expect ')' after parameters."))
    }
    // 解析函数体
    try attemp(consume: .LEFT_BRACE, else: ParseError.expectLeftBrace(token: currentToken,
                                                                      message: "Expect '{' before \(description) body."))
    let body = try blockStatement()
    return .functionDeclaration(name: name, params: params, body: body)
  }
  
  /// return语句
  private mutating func returnStatement() throws -> Statement {
    let keyword = previousToken!
    var expr: Expression? = nil
    if !check(type: .SEMICOLON) {
      expr = try expression()
    }
    try attemp(consume: .SEMICOLON, else: ParseError.expectSemicolon(token: currentToken, message: "Expect ';' after return value."))
    return .returnStatement(keyword: keyword, value: expr)
  }
  
  /// 表达式语句
  private mutating func expressionStatement() throws -> Statement {
    let expression = try expression()
    try attemp(consume: .SEMICOLON, else: ParseError.expectSemicolon(token: currentToken))
    return .expression(expression)
  }
  
  /// print语句
  private mutating func printStatement() throws -> Statement {
    let expression = try expression()
    try attemp(consume: .SEMICOLON, else: ParseError.expectSemicolon(token: currentToken))
    return .print(expression: expression)
  }
  
  /// 作用域块
  private mutating func blockStatement() throws -> Statement {
    var statements: [Statement] = []
    while !check(type: .RIGHT_BRACE) && !isAtEnd {
      statements.append(try statement())
    }
    try attemp(consume: .RIGHT_BRACE, else: ParseError.expectRightBrace(token: currentToken))
    return .block(statements: statements)
  }
  
  /// if块
  private mutating func ifStatement() throws -> Statement {
    try attemp(consume: .LEFT_PAREN, else: ParseError.expectLeftParen(token: currentToken))
    let condition = try expression()
    try attemp(consume: .RIGHT_PAREN, else: ParseError.expectRightParen(token: currentToken))
    let thenBranch = try statement()
    let elseBranch = match(types: .ELSE) ? try statement() : nil
    return .ifStatement(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
  }
  
  /// while块
  private mutating func whileStatement() throws -> Statement {
    try attemp(consume: .LEFT_PAREN, else: ParseError.expectLeftParen(token: currentToken))
    let condition = try expression()
    try attemp(consume: .RIGHT_PAREN, else: ParseError.expectRightParen(token: currentToken))
    let body = try statement()
    return .whileStatement(condition: condition, body: body)
  }
  
  /// for块
  ///
  ///     forStmt        → "for" "(" ( varDecl | exprStmt | ";" ) expression? ";" expression? ")" statement ;
  ///
  /// for语句的parse不会产生单独种类的statement，而是直接通过block嵌套while来实现
  private mutating func forStatement() throws -> Statement {
    try attemp(consume: .LEFT_PAREN, else: ParseError.expectLeftParen(token: currentToken))
    var initializer: Statement? = nil
    if !match(types: .SEMICOLON) {
      initializer = try statement()
    }
    var condition: Expression? = nil
    if !match(types: .SEMICOLON) {
      condition = try expression()
    }
    try attemp(consume: .SEMICOLON, else: ParseError.expectSemicolon(token: currentToken))
    var increment: Expression? = nil
    if !match(types: .RIGHT_PAREN) {
      increment = try expression()
    }
    try attemp(consume: .RIGHT_PAREN, else: ParseError.expectRightParen(token: currentToken))
    let body = try statement()
    var statements: [Statement] = []
    if initializer != nil {
      statements.append(initializer!)
    }
    let forBody = increment == nil ? body : .block(statements: [body, .expression(increment!)])
    statements.append(.whileStatement(condition: condition ?? .literal(value: true), body: forBody))
    return .block(statements: statements)
  }
  
  // MARK: - 解析表达式
  
  /// expression     → assignment
  mutating func expression() throws -> Expression {
    return try assignment()
  }
  
  /// 赋值表达式
  ///
  ///     assignment     → IDENTIFIER "=" assignment | logic_or
  private mutating func assignment() throws -> Expression {
    let expr = try or()
    if match(types: .EQUAL) {
      let equalToken = previousToken!
      let value = try assignment()
      guard case let Expression.variable(_, varName) = expr else {
        throw ParseError.invalidAssignmentTarget(token: equalToken)
      }
      return .assign(name: varName, value: value)
    }
    return expr
  }
  
  /// 逻辑或表达式
  ///
  ///     logic_or       → logic_and ( "or" logic_and )*
  private mutating func or() throws -> Expression {
    let left = try and()
    while match(types: .OR) {
      let op = previousToken!
      let right = try or()
      return .logical(left: left, op: op, right: right)
    }
    return left
  }
  
  /// 逻辑与表达式
  ///
  ///     logic_and      → equality ( "and" equality )*
  private mutating func and() throws -> Expression {
    let left = try equality()
    while match(types: .AND) {
      let op = previousToken!
      let right = try and()
      return .logical(left: left, op: op, right: right)
    }
    return left
  }
  
  /// 等式表达式
  ///
  ///     equality       → comparison ( ( "!=" | "==" ) comparison )*
  private mutating func equality() throws -> Expression {
    var expr = try comparsion()
    while match(types: .BANG_EQUAL, .EQUAL_EQUAL) {
      let op = previousToken!
      let right = try comparsion()
      expr = .binary(left: expr, right: right, op: op)
    }
    return expr
  }
  
  /// 比较表达式
  ///
  ///     comparison     → term ( ( ">" | ">=" | "<" | "<=" ) term )*
  private mutating func comparsion() throws -> Expression {
    var expr = try term()
    while match(types: .GREATER, .GREATER_EQUAL, .LESS, .LESS_EQUAL) {
      let op = previousToken!
      let right = try term()
      expr = .binary(left: expr, right: right, op: op)
    }
    return expr
  }
  
  /// 加减法表达式
  ///
  ///     term           → factor ( ( "-" | "+" ) factor )*
  private mutating func term() throws -> Expression {
    var expr = try factor()
    while match(types: .MINUS, .PLUS) {
      let op = previousToken!
      let right = try factor()
      expr = .binary(left: expr, right: right, op: op)
    }
    return expr
  }
  
  /// 乘除法表达式
  ///
  ///     factor         → unary ( ( "/" | "*" ) unary )*
  private mutating func factor() throws -> Expression {
    var expr = try unary()
    while match(types: .SLASH, .STAR) {
      let op = previousToken!
      let right = try unary()
      expr = .binary(left: expr, right: right, op: op)
    }
    return expr
  }
  
  /// 一元表达式
  ///
  ///     unary          → ( "!" | "-" ) unary | call
  private mutating func unary() throws -> Expression {
    if match(types: .BANG, .MINUS) {
      let op = previousToken!
      let right = try unary()
      return .unary(op: op, right: right)
    }
    return try call()
  }
  
  /// 调用表达式
  ///
  ///     call           → primary ( "(" arguments? ")" )*
  ///     arguments      → expression ( "," expression )*
  private mutating func call() throws -> Expression {
    func finish(callee: Expression) throws -> Expression {
      var arguments: [Expression] = []
      if !check(type: .RIGHT_PAREN)  {
        repeat {
          if arguments.count >= 255 {
            throw ParseError.tooManyArguments(token: currentToken)
          }
          arguments.append(try expression())
        } while(match(types: .COMMA))
      }
      try attemp(consume: .RIGHT_PAREN, else: ParseError.expectRightParen(token: currentToken))
      return .call(callee: callee, arguments: arguments, rightParen: previousToken!)
    }
    var call = try primary()
    while match(types: .LEFT_PAREN) {
      call = try finish(callee: call)
    }
    return call
  }
  
  /// 主表达式
  ///
  ///     primary        → NUMBER | STRING | "true" | "false" | "nil" | "(" expression ")" | IDENTIFIER
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
