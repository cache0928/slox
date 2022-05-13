//
//  Statement.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/5.
//

import Foundation

public enum Statement {
  // exprStmt       → expression ";"
  case expression(_: Expression)
  // printStmt      → "print" expression ";"
  case print(expression: Expression)
  // varDecl        → "var" IDENTIFIER ( "=" expression )? ";"
  case variableDeclaration(name: Token, initializer: Expression? = nil)
  // block          → "{" declaration* "}"
  case block(statements: [Statement])
}
