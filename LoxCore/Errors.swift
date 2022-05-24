//
//  Error.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/4/18.
//

import Foundation

public enum ScanError: Error, CustomStringConvertible {
  case unexpectedCharacter(line: Int)
  case unterminatedString(line: Int)
  case unterminatedComment(line: Int)
  
  public var description: String {
    switch self {
      case .unexpectedCharacter(let line):
        return "[line \(line)] Error: Unexpected character"
      case .unterminatedString(let line):
        return "[line \(line)] Error: Unterminated string"
      case .unterminatedComment(let line):
        return "[line \(line)] Error: Unterminated comment"
    }
  }
}

fileprivate func basicInfo(token: Token) -> String {
  return "[line \(token.line)] Error \(token.type == .EOF ? "at end" : "at '\(token.lexeme)'"):"
}

public enum ParseError: Error, CustomStringConvertible {
  case expectLeftParen(token: Token, message: String? = nil)
  case expectRightParen(token: Token, message: String? = nil)
  case expectExpression(token: Token)
  case expectSemicolon(token: Token, message: String? = nil)
  case expectVariableName(token: Token, message: String? = nil)
  case invalidAssignmentTarget(token: Token)
  case expectLeftBrace(token: Token, message: String? = nil)
  case expectRightBrace(token: Token, message: String? = nil)
  case tooManyArguments(token: Token, message: String? = nil)
  
  public var description: String {
    switch self {
      case .expectLeftParen(let token, let message):
        return "\(basicInfo(token: token)) \(message ?? "Expect '(' after expression.")"
      case .expectRightParen(let token, let message):
        return "\(basicInfo(token: token)) \(message ?? "Expect ')' after expression.")"
      case .expectExpression(let token):
        return "\(basicInfo(token: token)) Expect expression."
      case .expectSemicolon(let token, let message):
        return "\(basicInfo(token: token)) \(message ?? "Expect ';' after value.")"
      case .expectVariableName(let token, let message):
        return "\(basicInfo(token: token)) \(message ?? "Expect variable name.")"
      case .invalidAssignmentTarget(let token):
        return "\(basicInfo(token: token)) Invalid assignment target."
      case .expectLeftBrace(let token, let message):
        return "\(basicInfo(token: token)) \(message ?? "Expect '{' after expression.")"
      case .expectRightBrace(let token, let message):
        return "\(basicInfo(token: token)) \(message ?? "Expect '}' after expression.")"
      case .tooManyArguments(let token, let message):
        return "\(basicInfo(token: token)) \(message ?? "Can't have more than 255 arguments.")"
    }
  }
}

public enum RuntimeError: Error, CustomStringConvertible {
  case operandError(token: Token, message: String)
  case unknownError(token: Token, message: String)
  case undefinedVariable(token: Token)
  case invalidCallable(token: Token)
  case unexceptArgumentsCount(token: Token, expect: Int, got: Int)
  
  public var description: String {
    switch self {
      case .operandError(let token, let message),
          .unknownError(let token, let message):
        return "[line \(token.line)] Runtime Error at '\(token.lexeme)': \(message)"
      case .undefinedVariable(let token):
        return "\(basicInfo(token: token)) Undefined variable '\(token.lexeme)'."
      case .invalidCallable(let token):
        return "\(basicInfo(token: token)) Can only call functions and classes."
      case .unexceptArgumentsCount(let token, let expect, let got):
        return "\(basicInfo(token: token)) Expected \(expect) arguments but got \(got)."
      
    }
  }
}

public enum ResolvingError: Error, CustomStringConvertible {
  case undefinedVariable(token: Token)
  case variableRedeclaration(token: Token)
  case invalidReturn(token: Token, message: String)
  
  public var description: String {
    switch self {
      case .undefinedVariable(let token):
        return "\(basicInfo(token: token)) Can't read local variable in its own initializer."
      case .variableRedeclaration(let token):
        return "\(basicInfo(token: token)) Already a variable with this name in this scope."
      case .invalidReturn(let token, let message):
        return "\(basicInfo(token: token)) \(message)"
    }
  }
}
