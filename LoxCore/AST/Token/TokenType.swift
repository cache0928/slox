//
//  TokenType.swift
//  slox
//
//  Created by 徐才超 on 2022/4/18.
//

import Foundation

public enum TokenType: String {
  // Single-character tokens.
  case LEFT_PAREN = "(", RIGHT_PAREN = ")", LEFT_BRACE = "{", RIGHT_BRACE = "}",
  COMMA = ",", DOT = ".", MINUS = "-", PLUS = "+", SEMICOLON = ";", SLASH = "/", STAR = "*", COLON = ":",

  // One or two character tokens.
  BANG = "!", BANG_EQUAL = "!=",
  EQUAL = "=", EQUAL_EQUAL = "==",
  GREATER = ">", GREATER_EQUAL = ">=",
  LESS = "<", LESS_EQUAL = "<=",

  // Literals.
  IDENTIFIER, STRING, DOUBLE, INT,

  // Keywords.
  AND = "and", CLASS = "class", ELSE = "else", FALSE = "false", FUN = "fun",
  FOR = "for", IF = "if", NIL = "nil", OR = "or",
  PRINT = "print", RETURN = "return", SUPER = "super", THIS = "this", TRUE = "true", VAR = "var", WHILE = "while",

  EOF
}
