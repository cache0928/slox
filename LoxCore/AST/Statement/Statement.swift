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
  // exprStmt       → expression ";"
  case expression(_: Expression)
  // printStmt      → "print" expression ";"
  case print(expression: Expression)
  // varDecl        → "var" IDENTIFIER ( "=" expression )? ";"
  case variableDeclaration(name: Token, initializer: Expression? = nil)
  // block          → "{" statement* "}"
  case block(statements: [Statement])
  // ifStmt         → "if" "(" expression ")" statement ( "else" statement )?
  case ifStatement(condition: Expression, thenBranch: Statement, elseBranch: Statement?)
  // whileStmt      → "while" "(" expression ")" statement
  case whileStatement(condition: Expression, body: Statement)
  // funDecl        → "fun" IDENTIFIER "(" (IDENTIFIER ( "," IDENTIFIER )*)? ")" block
  case functionDeclaration(name: Token, params: [Token], body: Statement)
  // returnStmt     → "return" expression? ";"
  case returnStatement(keyword: Token, value: Expression? = nil)
}
