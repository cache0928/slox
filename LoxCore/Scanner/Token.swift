//
//  Token.swift
//  slox
//
//  Created by 徐才超 on 2022/4/18.
//

import Foundation

public struct Token: CustomStringConvertible {
  
  init(type: TokenType, lexeme: String, line: Int, literal: AnyLiteral? = nil) {
    self.type = type
    self.literal = literal
    self.lexeme = lexeme
    self.line = line
  }
  
  let type: TokenType
  let lexeme: String
  let line: Int
  let literal: (any AnyLiteral)?
  
  public var description: String {
    var msg =  "\(type) \(lexeme)"
    if let literal = literal {
      msg += " \(literal)"
    }
    return msg
  }
}
