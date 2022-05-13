//
//  StatementsTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/7.
//

import XCTest
@testable import LoxCore

class StatementsTests: XCTestCase {
  var interpreter: Interpreter!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    interpreter = Interpreter()
  }

  override func tearDownWithError() throws {
    interpreter = nil
    try super.tearDownWithError()
  }
  
  func testStatementExceptSemicon() {
    let code = "1 + 2"
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    XCTAssertThrowsError(try parser.statement())
  }
  
  func testExecuteExpressionStatement() {
    let statement = Statement.expression(.binary(left: .literal(value: 10),
                                                 right: .literal(value: 20),
                                                 op: Token(type: .PLUS, lexeme: "+", line: 1)))
    XCTAssertNoThrow(try interpreter.executed(statement: statement))
  }
  
  func testGetVariableBeforeDecalre() {
    let variableExpr = Expression.variable(name: Token(type: .IDENTIFIER, lexeme: "a", line: 1))
    XCTAssertThrowsError(try interpreter.evaluate(expression: variableExpr))
  }
  
  func testDeclareVariable() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let variableDeclStatement = Statement.variable(name: varName, initializer: .literal(value: 10))
    try! interpreter.executed(statement: variableDeclStatement)
    let variableExpr = Expression.variable(name: varName)
    XCTAssertEqual(ExpressionValue(rawValue: 10), try! interpreter.evaluate(expression: variableExpr))
  }
  
  func testDeclareVariableWithoutInitializer() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let variableDeclStatement = Statement.variable(name: varName)
    try! interpreter.executed(statement: variableDeclStatement)
    let variableExpr = Expression.variable(name: varName)
    XCTAssertEqual(ExpressionValue(rawValue: nil), try! interpreter.evaluate(expression: variableExpr))
  }
  
  func testAssignValueToExistVariable() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let variableDeclStatement = Statement.variable(name: varName, initializer: .literal(value: 10))
    try! interpreter.executed(statement: variableDeclStatement)
    let assignment = Expression.assign(name: varName, value: .literal(value: 100))
    try! interpreter.evaluate(expression: assignment)
    let variableExpr = Expression.variable(name: varName)
    XCTAssertEqual(ExpressionValue(rawValue: 100), try! interpreter.evaluate(expression: variableExpr))
  }
  
  func testAssignValueToNotExistVariable() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let assignment = Expression.assign(name: varName, value: .literal(value: 100))
    XCTAssertThrowsError(try interpreter.evaluate(expression: assignment))
  }
  
  func testAssignmentRecursivly() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let variableADeclStatement = Statement.variable(name: varA)
    try! interpreter.executed(statement: variableADeclStatement)
    let varB = Token(type: .IDENTIFIER, lexeme: "b", line: 1)
    let variableBDeclStatement = Statement.variable(name: varB)
    try! interpreter.executed(statement: variableBDeclStatement)
    let assignmentB = Expression.assign(name: varB, value: .literal(value: 100))
    let assignmentA = Expression.assign(name: varA, value: assignmentB)
    try! interpreter.evaluate(expression: assignmentA)
    let valueA = try! interpreter.evaluate(expression: Expression.variable(name: varA))
    let valueB = try! interpreter.evaluate(expression: Expression.variable(name: varB))
    XCTAssertEqual(valueB, ExpressionValue.intValue(raw: 100))
    XCTAssertEqual(valueA, valueB)
  }
  
}
