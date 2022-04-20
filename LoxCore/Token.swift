//
//  Token.swift
//  slox
//
//  Created by 徐才超 on 2022/4/18.
//

import Foundation

public struct Token: CustomStringConvertible {
  
  let type: TokenType
  let lexeme: String
  let line: Int
  let literal: Any?
  
  public var description: String {
    var msg =  "\(type) \(lexeme)"
    if let literal = literal {
      msg += " \(literal)"
    }
    return msg
  }
}
