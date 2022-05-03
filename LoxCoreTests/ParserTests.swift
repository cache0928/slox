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
    XCTAssertEqual(expr.description, "(* (- 123) (group 45.67))")
  }
  
  func testParsePrimary() {
    let bool = ["true", "false"]
    for c in bool {
      var scanner = Scanner(source: c)
      let tokens = try! scanner.scanTokens()
      var parser = Parser(tokens: tokens)
      if case let .literal(value) = parser.parse() {
        XCTAssertEqual(value as? Bool, Bool(c))
      } else {
        XCTFail()
      }
      
    }
    let number = "123.45"
    var scanner = Scanner(source: number)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .literal(value) = parser.parse() {
      XCTAssertEqual(value as! Double, 123.45)
    } else {
      XCTFail()
    }
    let string = "\"test string\""
    scanner = Scanner(source: string)
    parser = Parser(tokens: try! scanner.scanTokens())
    if case let .literal(value) = parser.parse() {
      XCTAssertEqual(value as! String, "test string")
    } else {
      XCTFail()
    }
    let nilString = "nil"
    scanner = Scanner(source: nilString)
    parser = Parser(tokens: try! scanner.scanTokens())
    if case let .literal(value) = parser.parse() {
      XCTAssertNil(value)
    } else {
      XCTFail()
    }
  }
  
  func testParseUnary() {
    let code = "!true"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .unary(op, right) = parser.parse(),
        case let .literal(value) = right {
      XCTAssertEqual(op.type, .BANG)
      XCTAssertEqual(value as? Bool, true)
    } else {
      XCTFail()
    }
  }
  
  func testParseFactor() {
    let code = "100 * 4.5"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .binary(left, right, op) = parser.parse(),
       case let .literal(leftValue) = left,
        case let .literal(rightValue) = right {
      XCTAssertEqual(op.type, .STAR)
      XCTAssertEqual(leftValue as? Int, 100)
      XCTAssertEqual(rightValue as? Double, 4.5)
    } else {
      XCTFail()
    }
  }
  
  func testParseTerm() {
    let code = "100 - 4.5"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .binary(left, right, op) = parser.parse(),
       case let .literal(leftValue) = left,
        case let .literal(rightValue) = right {
      XCTAssertEqual(op.type, .MINUS)
      XCTAssertEqual(leftValue as? Int, 100)
      XCTAssertEqual(rightValue as? Double, 4.5)
    } else {
      XCTFail()
    }
  }
  
  func testParseComparsion() {
    let code = "100 >= 4.5"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .binary(left, right, op) = parser.parse(),
       case let .literal(leftValue) = left,
        case let .literal(rightValue) = right {
      XCTAssertEqual(op.type, .GREATER_EQUAL)
      XCTAssertEqual(leftValue as? Int, 100)
      XCTAssertEqual(rightValue as? Double, 4.5)
    } else {
      XCTFail()
    }
  }
  
  func testParseEequality() {
    let code = "100 == 4.5"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .binary(left, right, op) = parser.parse(),
       case let .literal(leftValue) = left,
        case let .literal(rightValue) = right {
      XCTAssertEqual(op.type, .EQUAL_EQUAL)
      XCTAssertEqual(leftValue as? Int, 100)
      XCTAssertEqual(rightValue as? Double, 4.5)
    } else {
      XCTFail()
    }
  }
  
  func testExceptRightParen() {
    let code = "(1+2"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    XCTAssertNil(parser.parse())
  }
  
}
