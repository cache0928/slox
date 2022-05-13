//
//  Environment.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/12.
//

import Foundation

class Environment {
  private var values: [String: ExpressionValue] = [:]
  
  subscript(variable: Token) -> ExpressionValue {
    get throws {
      guard values.keys.contains(variable.lexeme) else {
        throw RuntimeError.undefinedVariable(token: variable)
      }
      return values[variable.lexeme]!
    }
  }
  
  func define(variable: Token, value: ExpressionValue) {
    values[variable.lexeme] = value
  }
  
  func redefine(variable: Token, value: ExpressionValue) throws {
    guard values.keys.contains(variable.lexeme) else {
      throw RuntimeError.undefinedVariable(token: variable)
    }
    values[variable.lexeme] = value
  }
}
