//
//  ParserTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/1.
//

import XCTest
@testable import LoxCore

class ExpressionTests: XCTestCase {
  var interpreter: Interpreter!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    interpreter = Interpreter()
  }

  override func tearDownWithError() throws {
    interpreter = nil
    try super.tearDownWithError()
  }
  
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
      var parser = Parser(tokens: [token, Token(type: .EOF, lexeme: "", line: 1)])
      if case let .literal(value) = try! parser.expression() {
        XCTAssertEqual(value as! Bool, token.literal as! Bool)
      } else {
        XCTFail()
      }
      
    }
    var parser = Parser(tokens: [
      Token(type: .DOUBLE, lexeme: "123.45", line: 1, literal: 123.45),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(value) = try! parser.expression() {
      XCTAssertEqual(value as! Double, 123.45)
    } else {
      XCTFail()
    }
    parser = Parser(tokens: [
      Token(type: .STRING, lexeme: "test string", line: 1, literal: "test string"),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(value) = try! parser.expression() {
      XCTAssertEqual(value as! String, "test string")
    } else {
      XCTFail()
    }
    parser = Parser(tokens: [
      Token(type: .NIL, lexeme: "nil", line: 1),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(value) = try! parser.expression() {
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
    if case let .unary(op, right) = try! parser.expression(),
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
    if case let .binary(left, right, op) = try! parser.expression(),
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
    if case let .binary(left, right, op) = try! parser.expression(),
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
    if case let .binary(left, right, op) = try! parser.expression(),
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
    if case let .binary(left, right, op) = try! parser.expression(),
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
    XCTAssertThrowsError(try parser.expression())
  }
  
  func testEvaluateLiteralExpression() {
    let numExpr = Expression.literal(value: 100)
    XCTAssertEqual(ExpressionValue(rawValue: 100), try! interpreter.evaluate(expression: numExpr))
    let strExpr = Expression.literal(value: "zxc")
    XCTAssertEqual(ExpressionValue(rawValue: "zxc"), try! interpreter.evaluate(expression: strExpr))
    let doubleExpr = Expression.literal(value: 12.34)
    XCTAssertEqual(ExpressionValue(rawValue: 12.34), try! interpreter.evaluate(expression: doubleExpr))
    let boolExpr = Expression.literal(value: true)
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.evaluate(expression: boolExpr))
  }
  
  func testEvaluateUnaryExpression() {
    let bangBoolExpr = Expression.unary(op: Token(type: .BANG, lexeme: "!", line: 1),
                                        right: Expression.literal(value: true))
    XCTAssertEqual(ExpressionValue(rawValue: false), try! interpreter.evaluate(expression: bangBoolExpr))
    let minusNumExpr = Expression.unary(op: Token(type: .MINUS, lexeme: "-", line: 1),
                                        right: Expression.literal(value: 1234))
    XCTAssertEqual(ExpressionValue(rawValue: -1234), try! interpreter.evaluate(expression: minusNumExpr))
    let bangStrExpr = Expression.unary(op: Token(type: .BANG, lexeme: "!", line: 1),
                                       right: Expression.literal(value: ""))
    XCTAssertEqual(ExpressionValue(rawValue: false), try! interpreter.evaluate(expression: bangStrExpr))
    let invalidMinusExpr = Expression.unary(op: Token(type: .MINUS, lexeme: "!", line: 1),
                                       right: Expression.literal(value: ""))
    XCTAssertThrowsError(try interpreter.evaluate(expression: invalidMinusExpr))
  }
  
  func testEvaluateBinaryExpression() {
    let numPlusExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .PLUS, lexeme: "+", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: 3.5), try! interpreter.evaluate(expression: numPlusExpr))
    let numMinusExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .MINUS, lexeme: "-", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: -1.5), try! interpreter.evaluate(expression: numMinusExpr))
    let numStarExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .STAR, lexeme: "*", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: 2.5), try! interpreter.evaluate(expression: numStarExpr))
    let numDivideExpr = Expression.binary(left: Expression.literal(value: 2.5),
                                        right: Expression.literal(value: 1),
                                        op: Token(type: .SLASH, lexeme: "/", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: 2.5), try! interpreter.evaluate(expression: numDivideExpr))
    let numGreaterExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .GREATER, lexeme: ">", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: false), try! interpreter.evaluate(expression: numGreaterExpr))
    let numLessExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .LESS, lexeme: "<", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.evaluate(expression: numLessExpr))
    let numGreaterEqualExpr = Expression.binary(left: Expression.literal(value: 2.5),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .GREATER_EQUAL, lexeme: ">=", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.evaluate(expression: numGreaterEqualExpr))
    let numLessEqualExpr = Expression.binary(left: Expression.literal(value: 2.5),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .LESS_EQUAL, lexeme: "<=", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.evaluate(expression: numLessEqualExpr))
    let strPlusExpr = Expression.binary(left: Expression.literal(value: "hello"),
                                        right: Expression.literal(value: "world"),
                                        op: Token(type: .PLUS, lexeme: "+", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: "helloworld"), try! interpreter.evaluate(expression: strPlusExpr))
    let equalEqualExpr = Expression.binary(left: Expression.literal(value: 2.5),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .EQUAL_EQUAL, lexeme: "==", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.evaluate(expression: equalEqualExpr))
    let bangEqualExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .BANG_EQUAL, lexeme: "!=", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.evaluate(expression: bangEqualExpr))
    let invalidPlusExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: ""),
                                        op: Token(type: .PLUS, lexeme: "+", line: 1))
    XCTAssertThrowsError(try interpreter.evaluate(expression: invalidPlusExpr))
  }
  
  func testEvaluateGroupExpression() {
    let numPlusExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .PLUS, lexeme: "+", line: 1))
    let groupPlusExpr = Expression.grouping(expression: numPlusExpr)
    XCTAssertEqual(ExpressionValue(rawValue: 3.5), try! interpreter.evaluate(expression: groupPlusExpr))
    let minusExpr = Expression.binary(left: Expression.literal(value: 2),
                                      right: groupPlusExpr,
                                      op: Token(type: .STAR, lexeme: "*", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: 7), try! interpreter.evaluate(expression: minusExpr))
  }
  
  func testEvaluateVariableExpression() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    try! interpreter.executed(statement: .variableDeclaration(name: varA, initializer: .literal(value: 1)))
    XCTAssertEqual(ExpressionValue(rawValue: 1), try! interpreter.evaluate(expression: Expression.variable(name: varA)))
  }
}
