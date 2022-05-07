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

public enum ParseError: Error, CustomStringConvertible {
  case expectParen(token: Token)
  case expectExpression(token: Token)
  case expectSemicolon(token: Token)
  
  public var description: String {
    switch self {
      case .expectParen(let token):
        return "[line \(token.line)] Error \((token.type == .EOF ? "at end" : "at '\(token.lexeme)'") + ": Expect ')' after expression.")"
      case .expectExpression(let token):
        return "[line \(token.line)] Error \((token.type == .EOF ? "at end" : "at '\(token.lexeme)'") + ": Expect expression.")"
      case .expectSemicolon(let token):
        return "[line \(token.line)] Error \((token.type == .EOF ? "at end" : "at '\(token.lexeme)'") + ": Expect ';' after value.")"
    }
  }
}

public enum RuntimeError: Error, CustomStringConvertible {
  case operandError(token: Token, message: String)
  case unknownError(token: Token, message: String)
  
  public var description: String {
    switch self {
      case .operandError(let token, let message),
          .unknownError(let token, let message):
        return "[line \(token.line)] Runtime Error at '\(token.lexeme)': \(message)"
    }
  }

}
