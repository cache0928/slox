//
//  Interpreter.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/4.
//

import Foundation

public struct Interpreter: Sequence {
  public typealias Element = Result<ExpressionValue?, Error>
  public typealias Iterator = StatementsIterator
  
  let statements: [Statement]
  
  public init(source: String) throws {
    var scanner = Scanner(source: source)
    let tokens = try scanner.scanTokens()
    var parser = Parser(tokens: tokens)
    self.statements = try parser.parse()
  }
  
  public func makeIterator() -> Self.Iterator {
    return StatementsIterator(statements: statements)
  }
}

public struct StatementsIterator: IteratorProtocol {
  public mutating func next() -> Result<ExpressionValue?, Error>? {
    guard index < statements.count else {
      return nil
    }
    defer {
      index += 1
    }
    do {
      let value = try statements[index].executed
      return .success(value)
    } catch {
      return .failure(error)
    }
  }
  
  let statements: [Statement]
  var index = 0
  public typealias Element = Result<ExpressionValue?, Error>
}
