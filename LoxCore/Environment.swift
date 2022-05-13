//
//  Environment.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/12.
//

import Foundation

final class Environment {
  private var values: [String: ExpressionValue] = [:]
  private let enclosing: Environment?
  
  init(enclosing: Environment? = nil) {
    self.enclosing = enclosing
  }
  
  subscript(variable: Token) -> ExpressionValue {
    get throws {
      guard values.keys.contains(variable.lexeme) else {
        if let parent = enclosing {
          return try parent[variable]
        }
        throw RuntimeError.undefinedVariable(token: variable)
      }
      return values[variable.lexeme]!
    }
  }
  
  func define(variable: Token, value: ExpressionValue) {
    values[variable.lexeme] = value
  }
  
  func assign(variable: Token, value: ExpressionValue) throws {
    guard values.keys.contains(variable.lexeme) else {
      if let parent = enclosing {
        try parent.assign(variable: variable, value: value)
        return
      }
      throw RuntimeError.undefinedVariable(token: variable)
    }
    values[variable.lexeme] = value
  }
}
