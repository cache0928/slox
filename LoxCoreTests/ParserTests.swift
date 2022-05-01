//
//  ParserTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/1.
//

import XCTest
@testable import LoxCore

class ParserTests: XCTestCase {
  
  func testAstDescription() {
    let expr = Expression.binary(
      left: .unary(op: Token(type: .MINUS, lexeme: "-", line: 1), right: .literal(value: 123)),
      right: .grouping(expression: .literal(value: 45.67)),
      op: Token(type: .STAR, lexeme: "*", line: 1)
    )
    XCTAssertEqual(expr.description, "(* (- 123.0) (group 45.67))")
  }
  
}
