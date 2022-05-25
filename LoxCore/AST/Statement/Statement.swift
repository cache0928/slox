//
//  Statement.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/5.
//

import Foundation

enum ReturnValue: Error {
  case value(_: ExpressionValue = ExpressionValue.anyValue(raw: ()))
}

public indirect enum Statement {
  /// 表达式语句
  ///
  ///     exprStmt       → expression ";"
  case expression(_: Expression)
  /// print语句
  ///
  ///     printStmt      → "print" expression ";"
  case print(expression: Expression)
  /// 变量定义语句
  ///
  ///     varDecl        → "var" IDENTIFIER ( "=" expression )? ";"
  case variableDeclaration(name: Token, initializer: Expression? = nil)
  /// 块语句
  ///
  ///     block          → "{" statement* "}"
  case block(statements: [Statement])
  /// if语句
  ///
  ///     ifStmt         → "if" "(" expression ")" statement ( "else" statement )?
  case ifStatement(condition: Expression, thenBranch: Statement, elseBranch: Statement?)
  /// while语句
  ///
  ///     whileStmt      → "while" "(" expression ")" statement
  case whileStatement(condition: Expression, body: Statement)
  /// 函数定义语句
  ///
  ///     funDecl        → "fun" IDENTIFIER "(" (IDENTIFIER ( "," IDENTIFIER )*)? ")" block
  case functionDeclaration(name: Token, params: [Token], body: Statement)
  /// return语句
  ///
  ///     returnStmt     → "return" expression? ";"
  case returnStatement(keyword: Token, value: Expression? = nil)
  /// class定义语句
  ///
  ///     classDecl      → "class" IDENTIFIER "{" function* "}"
  case classStatement(name: Token, methods: [Statement])
}
