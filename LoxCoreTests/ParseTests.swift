//
//  ParserTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/1.
//

import XCTest
@testable import LoxCore

class ParseTests: XCTestCase {
  
  func testAstDescription() {
    let expr = Expression.binary(
      left: .unary(op: Token(type: .MINUS, lexeme: "-", line: 1), right: .literal(value: 123)),
      right: .grouping(expression: .literal(value: 45.67)),
      op: Token(type: .STAR, lexeme: "*", line: 1)
    )
    XCTAssertEqual(expr.description, "(* (- 123) (group 45.67))")
  }
  
  func testParsePrimary() {
    let boolTokens = [
      Token(type: .TRUE, lexeme: "true", line: 1, literal: true),
      Token(type: .FALSE, lexeme: "false", line: 1, literal: false),
    ]
    for token in boolTokens {
      var parser = Parser(tokens: [token])
      if case let .literal(value) = try! parser.parse() {
        XCTAssertEqual(value as! Bool, token.literal as! Bool)
      } else {
        XCTFail()
      }
      
    }
    var parser = Parser(tokens: [
      Token(type: .DOUBLE, lexeme: "123.45", line: 1, literal: 123.45),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(value) = try! parser.parse() {
      XCTAssertEqual(value as! Double, 123.45)
    } else {
      XCTFail()
    }
    parser = Parser(tokens: [
      Token(type: .STRING, lexeme: "test string", line: 1, literal: "test string"),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(value) = try! parser.parse() {
      XCTAssertEqual(value as! String, "test string")
    } else {
      XCTFail()
    }
    parser = Parser(tokens: [
      Token(type: .NIL, lexeme: "nil", line: 1),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(value) = try! parser.parse() {
      XCTAssertNil(value)
    } else {
      XCTFail()
    }
  }
  
  func testParseUnary() {
    var parser = Parser(tokens: [
      Token(type: .BANG, lexeme: "!", line: 1),
      Token(type: .TRUE, lexeme: "true", line: 1, literal: true),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .unary(op, right) = try! parser.parse(),
        case let .literal(value) = right {
      XCTAssertEqual(op.type, .BANG)
      XCTAssertEqual(value as? Bool, true)
    } else {
      XCTFail()
    }
  }
  
  func testParseFactor() {
    var parser = Parser(tokens: [
      Token(type: .INT, lexeme: "100", line: 1, literal: 100),
      Token(type: .STAR, lexeme: "*", line: 1),
      Token(type: .DOUBLE, lexeme: "4.5", line: 1, literal: 4.5),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .binary(left, right, op) = try! parser.parse(),
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
    var parser = Parser(tokens: [
      Token(type: .INT, lexeme: "100", line: 1, literal: 100),
      Token(type: .MINUS, lexeme: "-", line: 1),
      Token(type: .DOUBLE, lexeme: "4.5", line: 1, literal: 4.5),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .binary(left, right, op) = try! parser.parse(),
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
    var parser = Parser(tokens: [
      Token(type: .INT, lexeme: "100", line: 1, literal: 100),
      Token(type: .GREATER_EQUAL, lexeme: ">=", line: 1),
      Token(type: .DOUBLE, lexeme: "4.5", line: 1, literal: 4.5),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .binary(left, right, op) = try! parser.parse(),
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
    var parser = Parser(tokens: [
      Token(type: .INT, lexeme: "100", line: 1, literal: 100),
      Token(type: .EQUAL_EQUAL, lexeme: "==", line: 1),
      Token(type: .DOUBLE, lexeme: "4.5", line: 1, literal: 4.5),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .binary(left, right, op) = try! parser.parse(),
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
    var parser = Parser(tokens: [
      Token(type: .LEFT_PAREN, lexeme: "(", line: 1),
      Token(type: .INT, lexeme: "1", line: 1, literal: 1),
      Token(type: .PLUS, lexeme: "+", line: 1),
      Token(type: .INT, lexeme: "2", line: 1, literal: 2),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    XCTAssertThrowsError(try parser.parse())
  }
  
}
