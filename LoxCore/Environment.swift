//
//  Environment.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/12.
//

import Foundation

final class Environment {
  private var values: [String: ExpressionValue] = [:]
  private(set) var enclosing: Environment?
  
  init(enclosing: Environment? = nil) {
    self.enclosing = enclosing
  }
  
  func set(enclosing: Environment) {
    self.enclosing = enclosing
  }
  
  func define(variableName: String, value: ExpressionValue) {
    values[variableName] = value
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
  
  func get(variable: Token) throws -> ExpressionValue {
    guard values.keys.contains(variable.lexeme) else {
      if let parent = enclosing {
        return try parent.get(variable: variable)
      }
      throw RuntimeError.undefinedVariable(token: variable)
    }
    return values[variable.lexeme]!
  }
}
