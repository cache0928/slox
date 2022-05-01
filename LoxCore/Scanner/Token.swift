//
//  Token.swift
//  slox
//
//  Created by 徐才超 on 2022/4/18.
//

import Foundation

protocol AnyLiteral: CustomStringConvertible {
  
}

extension String: AnyLiteral {
  var description: String {
    return self
  }
}

extension Double: AnyLiteral {
  var description: String {
    return String(self)
  }
}

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
