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
      var parser = Parser(tokens: [token, Token(type: .EOF, lexeme: "", line: 1)])
      if case let .literal(_, value) = try! parser.expression() {
        XCTAssertEqual(value as! Bool, token.literal as! Bool)
      } else {
        XCTFail()
      }
      
    }
    var parser = Parser(tokens: [
      Token(type: .DOUBLE, lexeme: "123.45", line: 1, literal: 123.45),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(_, value) = try! parser.expression() {
      XCTAssertEqual(value as! Double, 123.45)
    } else {
      XCTFail()
    }
    parser = Parser(tokens: [
      Token(type: .STRING, lexeme: "test string", line: 1, literal: "test string"),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(_, value) = try! parser.expression() {
      XCTAssertEqual(value as! String, "test string")
    } else {
      XCTFail()
    }
    parser = Parser(tokens: [
      Token(type: .NIL, lexeme: "nil", line: 1),
      Token(type: .EOF, lexeme: "", line: 1)
    ])
    if case let .literal(_, value) = try! parser.expression() {
      XCTAssertNil(value)
    } else {
      XCTFail()
    }
  }
  
  func testParseGroup() {
    let code = "( 1 + 2.5 )"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case .grouping(_, let expression) = try! parser.expression(),
       case .binary(_, let left, let right, let op) = expression,
       case .literal(_, let rightValue) = right,
       case .literal(_, let leftValue) = left {
      XCTAssertEqual(op.type, .PLUS)
      XCTAssertEqual(leftValue as? Int, 1)
      XCTAssertEqual(rightValue as? Double, 2.5)
    } else {
      XCTFail()
    }
  }
  
  func testParseUnaryExpression() {
    var code = "!true"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .unary(_, op, right) = try! parser.expression(),
       case let .literal(_, value) = right {
      XCTAssertEqual(op.type, .BANG)
      XCTAssertEqual(value as? Bool, true)
    } else {
      XCTFail()
    }
    code = "-(100 + 100)"
    scanner = Scanner(source: code)
    parser = Parser(tokens: try! scanner.scanTokens())
    if case let .unary(_, op, right) = try! parser.expression(),
       case let .grouping(_, expr) = right,
       case let .binary(_, _, _, groupOp) = expr {
      XCTAssertEqual(op.type, .MINUS)
      XCTAssertEqual(groupOp.type, .PLUS)
    } else {
      XCTFail()
    }
  }
  
  func testParseFactorExpression() {
    let code = "100 * -4.5"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .binary(_, left, right, op) = try! parser.expression(),
       case let .literal(_, leftValue) = left,
       case let .unary(_, unaryOp, unaryExpr) = right,
       case let .literal(_, unaryValue) = unaryExpr {
      XCTAssertEqual(op.type, .STAR)
      XCTAssertEqual(leftValue as? Int, 100)
      XCTAssertEqual(unaryOp.type, .MINUS)
      XCTAssertEqual(unaryValue as? Double, 4.5)
    } else {
      XCTFail()
    }
  }
  
  func testParseTermExpression() {
    let code = "100 - 4.5"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .binary(_, left, right, op) = try! parser.expression(),
       case let .literal(_, leftValue) = left,
       case let .literal(_, rightValue) = right {
      XCTAssertEqual(op.type, .MINUS)
      XCTAssertEqual(leftValue as? Int, 100)
      XCTAssertEqual(rightValue as? Double, 4.5)
    } else {
      XCTFail()
    }
  }
  
  func testParseComparsionExpression() {
    let code = "100 >= 4.5"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .binary(_, left, right, op) = try! parser.expression(),
       case let .literal(_, leftValue) = left,
        case let .literal(_, rightValue) = right {
      XCTAssertEqual(op.type, .GREATER_EQUAL)
      XCTAssertEqual(leftValue as? Int, 100)
      XCTAssertEqual(rightValue as? Double, 4.5)
    } else {
      XCTFail()
    }
  }
  
  func testParseEqualityExpression() {
    let code = "100 == 4.5"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .binary(_, left, right, op) = try! parser.expression(),
       case let .literal(_, leftValue) = left,
        case let .literal(_, rightValue) = right {
      XCTAssertEqual(op.type, .EQUAL_EQUAL)
      XCTAssertEqual(leftValue as? Int, 100)
      XCTAssertEqual(rightValue as? Double, 4.5)
    } else {
      XCTFail()
    }
  }
  
  func testParseVariableExpression() {
    let code = "a"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .variable(_, name) = try! parser.expression() {
      XCTAssertEqual(name.type, .IDENTIFIER)
    } else {
      XCTFail()
    }
  }
  
  func testParseFunctionExpression() {
    let code = "test()"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .call(_, callee, arguments, _) = try! parser.expression(),
       case let .variable(_, name) = callee {
      XCTAssertEqual(name.type, .IDENTIFIER)
      XCTAssertTrue(arguments.isEmpty)
    } else {
      XCTFail()
    }
  }
  
  func testParseFunctionDeclarationWithParameters() {
    let code = "fun test(a, b) { return a + b; }"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .functionDeclaration(name, params, _) = try! parser.statement() {
      XCTAssertEqual(name.type, .IDENTIFIER)
      XCTAssertTrue(params.count == 2)
    } else {
      XCTFail()
    }
  }
  
  func testParseFunctionDeclarationWithoutParameters() {
    let code = "fun test() { return; }"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .functionDeclaration(name, params, _) = try! parser.statement() {
      XCTAssertEqual(name.type, .IDENTIFIER)
      XCTAssertTrue(params.count == 0)
    } else {
      XCTFail()
    }
  }
  
  func testParseClassDeclaration() {
    let code = "class A: B { method() {} }"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .classStatement(name, superclass, methods) = try! parser.statement(),
       case let .variable(_, superName) = superclass {
      XCTAssertEqual(superName.type, .IDENTIFIER)
      XCTAssertEqual(superName.lexeme, "B")
      XCTAssertEqual(name.type, .IDENTIFIER)
      XCTAssertEqual(name.lexeme, "A")
      XCTAssertTrue(methods.count == 1)
    } else {
      XCTFail()
    }
  }
  
  func testParseGetInstanceProperty() {
    let code = "instance.property;"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    if case let .expression(expr) = try! parser.statement(),
       case let .getter(_, object, propertyName) = expr,
       case let .variable(_, objName) = object {
      XCTAssertEqual(objName.type, .IDENTIFIER)
      XCTAssertEqual(objName.lexeme, "instance")
      XCTAssertEqual(propertyName.type, .IDENTIFIER)
      XCTAssertEqual(propertyName.lexeme, "property")
    } else {
      XCTFail()
    }
  }
  
  func testExceptRightParen() {
    let code = "( 1 + 2"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    XCTAssertThrowsError(try parser.expression())
  }
  
  func testStatementExceptSemicon() {
    let code = "1 + 2"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    XCTAssertThrowsError(try parser.statement())
  }
  
}
