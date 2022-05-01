//
//  String+TokenType.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/4/29.
//

let keywords: [String: TokenType] = [
  "and": .AND,
  "class": .CLASS,
  "else": .ELSE,
  "false": .FALSE,
  "for": .FOR,
  "fun": .FUN,
  "if": .IF,
  "nil": .NIL,
  "or": .OR,
  "print": .PRINT,
  "return": .RETURN,
  "super": .SUPER,
  "this": .THIS,
  "true": .TRUE,
  "var": .VAR,
  "while": .WHILE,
]

extension String {
  var tokenType: TokenType? {
    switch self {
      case "(":
        return .LEFT_PAREN
      case ")":
        return .RIGHT_PAREN
      case "{":
        return .LEFT_BRACE
      case "}":
        return .RIGHT_BRACE
      case ",":
        return .COMMA
      case ".":
        return .DOT
      case "-":
        return .MINUS
      case "+":
        return .PLUS
      case ";":
        return .SEMICOLON
      case "*":
        return .STAR
      case "=":
        return .EQUAL
      case "==":
        return .EQUAL_EQUAL
      case "!":
        return .BANG
      case "!=":
        return .BANG_EQUAL
      case "<":
        return .LESS
      case "<=":
        return .LESS_EQUAL
      case ">":
        return .GREATER
      case ">=":
        return .GREATER_EQUAL
      case "/":
        return .SLASH
      default:
        return keywords[self]
    }
  }
}
