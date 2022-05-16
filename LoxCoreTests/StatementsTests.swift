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
    let code = "var a = 10;"
    try! interpreter.interpret(code: code)
    let variableExpr = Expression.variable(name: varName)
    XCTAssertEqual(ExpressionValue(rawValue: 10), try! interpreter.evaluate(expression: variableExpr))
  }
  
  func testDeclareVariableWithoutInitializer() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let variableDeclStatement = Statement.variableDeclaration(name: varName)
    try! interpreter.executed(statement: variableDeclStatement)
    let variableExpr = Expression.variable(name: varName)
    XCTAssertEqual(ExpressionValue(rawValue: nil), try! interpreter.evaluate(expression: variableExpr))
  }
  
  func testAssignValueToExistVariable() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a = 10;
               a = 100;
               """
    try! interpreter.interpret(code: code)
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
    let varB = Token(type: .IDENTIFIER, lexeme: "b", line: 1)
    let code = """
               var a;
               var b;
               a = b = 100;
               """
    try! interpreter.interpret(code: code)
    let valueA = try! interpreter.evaluate(expression: Expression.variable(name: varA))
    let valueB = try! interpreter.evaluate(expression: Expression.variable(name: varB))
    XCTAssertEqual(valueB, ExpressionValue.intValue(raw: 100))
    XCTAssertEqual(valueA, valueB)
  }
  
  func testBlockEnvironmentStackPush() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a = 1;
               {
                 var a = 1;
                 a = 10;
               }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.evaluate(expression: .variable(name: varA)), ExpressionValue.intValue(raw: 1))
  }
  
  func testBlockEnvironmentStackPop() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               {
                 var a = 100;
               }
               """
    try! interpreter.interpret(code: code)
    XCTAssertThrowsError(try interpreter.evaluate(expression: .variable(name: varA)))
  }
  
  func testIfStatementThenBranchExecute() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a;
               if (true) { a = true; } else { a = false; }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.evaluate(expression: .variable(name: varA)), ExpressionValue.boolValue(raw: true))
  }
  
  func testIfStatementElseBranchExecute() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a;
               if (false) { a = true; } else { a = false; }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.evaluate(expression: .variable(name: varA)), ExpressionValue.boolValue(raw: false))
  }
  
  func testWhileStatementExecute() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a = 1;
               while (a < 3) { a = a + 1; }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.evaluate(expression: .variable(name: varA)), ExpressionValue.intValue(raw: 3))
  }
  
  func testForStatementExecute() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a = 0;
               for(var i = 0; i < 3; i = i + 1) { a = a + 1; }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.evaluate(expression: .variable(name: varA)), ExpressionValue.intValue(raw: 3))
  }

}
