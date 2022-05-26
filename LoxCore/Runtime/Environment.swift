//
//  Environment.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/12.
//

import Foundation

final class Environment: CustomStringConvertible {
  private var values: [String: ExpressionValue] = [:]
  private let enclosing: Environment?
  
  var description: String {
    return "{\(values), enclosing: \(enclosing?.description ?? "nil")}"
  }
  
  init(enclosing: Environment? = nil) {
    self.enclosing = enclosing
  }
  
  private func ancestor(distance: Int) -> Environment? {
    var env: Environment? = self
    for _ in 0 ..< distance {
      env = env?.enclosing
    }
    return env
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
  
  func assign(variable: Token, value: ExpressionValue, at distance: Int) throws {
    let ancestor = ancestor(distance: distance)
    guard ancestor?.values.keys.contains(variable.lexeme) == true else {
      throw RuntimeError.undefinedVariable(token: variable)
    }
    ancestor!.values[variable.lexeme] = value
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
  
  func get(variable: Token, at distance: Int) throws -> ExpressionValue {
    let ancestor = ancestor(distance: distance)
    guard ancestor?.values.keys.contains(variable.lexeme) == true else {
      throw RuntimeError.undefinedVariable(token: variable)
    }
    return ancestor!.values[variable.lexeme]!
  }
}
