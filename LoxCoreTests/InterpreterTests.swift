//
//  StatementsTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/7.
//

import XCTest
@testable import LoxCore

class InterpreterTests: XCTestCase {
  var interpreter: Interpreter!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    interpreter = Interpreter()
  }

  override func tearDownWithError() throws {
    interpreter = nil
    try super.tearDownWithError()
  }
  
  func testEvaluateLiteralExpression() {
    let numExpr = Expression.literal(value: 100)
    XCTAssertEqual(ExpressionValue(rawValue: 100), try! interpreter.visit(expression: numExpr))
    let strExpr = Expression.literal(value: "zxc")
    XCTAssertEqual(ExpressionValue(rawValue: "zxc"), try! interpreter.visit(expression: strExpr))
    let doubleExpr = Expression.literal(value: 12.34)
    XCTAssertEqual(ExpressionValue(rawValue: 12.34), try! interpreter.visit(expression: doubleExpr))
    let boolExpr = Expression.literal(value: true)
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.visit(expression: boolExpr))
  }
  
  func testEvaluateUnaryExpression() {
    let bangBoolExpr = Expression.unary(op: Token(type: .BANG, lexeme: "!", line: 1),
                                        right: Expression.literal(value: true))
    XCTAssertEqual(ExpressionValue(rawValue: false), try! interpreter.visit(expression: bangBoolExpr))
    let minusNumExpr = Expression.unary(op: Token(type: .MINUS, lexeme: "-", line: 1),
                                        right: Expression.literal(value: 1234))
    XCTAssertEqual(ExpressionValue(rawValue: -1234), try! interpreter.visit(expression: minusNumExpr))
    let bangStrExpr = Expression.unary(op: Token(type: .BANG, lexeme: "!", line: 1),
                                       right: Expression.literal(value: ""))
    XCTAssertEqual(ExpressionValue(rawValue: false), try! interpreter.visit(expression: bangStrExpr))
    let invalidMinusExpr = Expression.unary(op: Token(type: .MINUS, lexeme: "!", line: 1),
                                       right: Expression.literal(value: ""))
    XCTAssertThrowsError(try interpreter.visit(expression: invalidMinusExpr))
  }
  
  func testEvaluateBinaryExpression() {
    let numPlusExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .PLUS, lexeme: "+", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: 3.5), try! interpreter.visit(expression: numPlusExpr))
    let numMinusExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .MINUS, lexeme: "-", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: -1.5), try! interpreter.visit(expression: numMinusExpr))
    let numStarExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .STAR, lexeme: "*", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: 2.5), try! interpreter.visit(expression: numStarExpr))
    let numDivideExpr = Expression.binary(left: Expression.literal(value: 2.5),
                                        right: Expression.literal(value: 1),
                                        op: Token(type: .SLASH, lexeme: "/", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: 2.5), try! interpreter.visit(expression: numDivideExpr))
    let numGreaterExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .GREATER, lexeme: ">", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: false), try! interpreter.visit(expression: numGreaterExpr))
    let numLessExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .LESS, lexeme: "<", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.visit(expression: numLessExpr))
    let numGreaterEqualExpr = Expression.binary(left: Expression.literal(value: 2.5),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .GREATER_EQUAL, lexeme: ">=", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.visit(expression: numGreaterEqualExpr))
    let numLessEqualExpr = Expression.binary(left: Expression.literal(value: 2.5),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .LESS_EQUAL, lexeme: "<=", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.visit(expression: numLessEqualExpr))
    let strPlusExpr = Expression.binary(left: Expression.literal(value: "hello"),
                                        right: Expression.literal(value: "world"),
                                        op: Token(type: .PLUS, lexeme: "+", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: "helloworld"), try! interpreter.visit(expression: strPlusExpr))
    let equalEqualExpr = Expression.binary(left: Expression.literal(value: 2.5),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .EQUAL_EQUAL, lexeme: "==", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.visit(expression: equalEqualExpr))
    let bangEqualExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .BANG_EQUAL, lexeme: "!=", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: true), try! interpreter.visit(expression: bangEqualExpr))
    let invalidPlusExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: ""),
                                        op: Token(type: .PLUS, lexeme: "+", line: 1))
    XCTAssertThrowsError(try interpreter.visit(expression: invalidPlusExpr))
  }
  
  func testEvaluateGroupExpression() {
    let numPlusExpr = Expression.binary(left: Expression.literal(value: 1),
                                        right: Expression.literal(value: 2.5),
                                        op: Token(type: .PLUS, lexeme: "+", line: 1))
    let groupPlusExpr = Expression.grouping(expression: numPlusExpr)
    XCTAssertEqual(ExpressionValue(rawValue: 3.5), try! interpreter.visit(expression: groupPlusExpr))
    let minusExpr = Expression.binary(left: Expression.literal(value: 2),
                                      right: groupPlusExpr,
                                      op: Token(type: .STAR, lexeme: "*", line: 1))
    XCTAssertEqual(ExpressionValue(rawValue: 7), try! interpreter.visit(expression: minusExpr))
  }
  
  func testEvaluateVariableExpression() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    try! interpreter.visit(statement: .variableDeclaration(name: varA, initializer: .literal(value: 1)))
    XCTAssertEqual(ExpressionValue(rawValue: 1), try! interpreter.visit(expression: Expression.variable(name: varA)))
  }
  
  func testEvaluateLogicalAndExpression() {
    let expr = Expression.logical(left: .literal(value: true),
                                  op: Token(type: .AND, lexeme: "and", line: 1),
                                  right: .literal(value: false))
    XCTAssertEqual(try! interpreter.visit(expression: expr), ExpressionValue.boolValue(raw: false))
    let expr2 = Expression.logical(left: .literal(value: nil),
                                  op: Token(type: .AND, lexeme: "and", line: 1),
                                  right: .literal(value: 1))
    XCTAssertEqual(try! interpreter.visit(expression: expr2), ExpressionValue.boolValue(raw: false))
    let expr3 = Expression.logical(left: .literal(value: true),
                                  op: Token(type: .AND, lexeme: "and", line: 1),
                                  right: .literal(value: true))
    XCTAssertEqual(try! interpreter.visit(expression: expr3), ExpressionValue.boolValue(raw: true))
  }
  
  func testEvaluateLogicalOrExpression() {
    let expr = Expression.logical(left: .literal(value: true),
                                  op: Token(type: .OR, lexeme: "or", line: 1),
                                  right: .literal(value: false))
    XCTAssertEqual(try! interpreter.visit(expression: expr), ExpressionValue.boolValue(raw: true))
    let expr2 = Expression.logical(left: .literal(value: nil),
                                  op: Token(type: .OR, lexeme: "or", line: 1),
                                  right: .literal(value: 1))
    XCTAssertEqual(try! interpreter.visit(expression: expr2), ExpressionValue.boolValue(raw: true))
    let expr3 = Expression.logical(left: .literal(value: false),
                                  op: Token(type: .OR, lexeme: "or", line: 1),
                                  right: .literal(value: false))
    XCTAssertEqual(try! interpreter.visit(expression: expr3), ExpressionValue.boolValue(raw: false))
  }
  
  func testExecuteExpressionStatement() {
    let statement = Statement.expression(.binary(left: .literal(value: 10),
                                                 right: .literal(value: 20),
                                                 op: Token(type: .PLUS, lexeme: "+", line: 1)))
    XCTAssertNoThrow(try interpreter.visit(statement: statement))
  }
  
  func testGetVariableBeforeDecalre() {
    let variableExpr = Expression.variable(name: Token(type: .IDENTIFIER, lexeme: "a", line: 1))
    XCTAssertThrowsError(try interpreter.visit(expression: variableExpr))
  }
  
  func testDeclareVariable() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = "var a = 10;"
    try! interpreter.interpret(code: code)
    let variableExpr = Expression.variable(name: varName)
    XCTAssertEqual(ExpressionValue(rawValue: 10), try! interpreter.visit(expression: variableExpr))
  }
  
  func testDeclareVariableWithoutInitializer() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let variableDeclStatement = Statement.variableDeclaration(name: varName)
    try! interpreter.visit(statement: variableDeclStatement)
    let variableExpr = Expression.variable(name: varName)
    XCTAssertEqual(ExpressionValue(rawValue: nil), try! interpreter.visit(expression: variableExpr))
  }
  
  func testAssignValueToExistVariable() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a = 10;
               a = 100;
               """
    try! interpreter.interpret(code: code)
    let variableExpr = Expression.variable(name: varName)
    XCTAssertEqual(ExpressionValue(rawValue: 100), try! interpreter.visit(expression: variableExpr))
  }
  
  func testAssignValueToNotExistVariable() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let assignment = Expression.assign(name: varName, value: .literal(value: 100))
    XCTAssertThrowsError(try interpreter.visit(expression: assignment))
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
    let valueA = try! interpreter.visit(expression: Expression.variable(name: varA))
    let valueB = try! interpreter.visit(expression: Expression.variable(name: varB))
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
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varA)), ExpressionValue.intValue(raw: 1))
  }
  
  func testBlockEnvironmentStackPop() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               {
                 var a = 100;
               }
               """
    try! interpreter.interpret(code: code)
    XCTAssertThrowsError(try interpreter.visit(expression: .variable(name: varA)))
  }
  
  func testIfStatementThenBranchExecute() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a;
               if (true) { a = true; } else { a = false; }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varA)), ExpressionValue.boolValue(raw: true))
  }
  
  func testIfStatementElseBranchExecute() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a;
               if (false) { a = true; } else { a = false; }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varA)), ExpressionValue.boolValue(raw: false))
  }
  
  func testWhileStatementExecute() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a = 1;
               while (a < 3) { a = a + 1; }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varA)), ExpressionValue.intValue(raw: 3))
  }
  
  func testForStatementExecute() {
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a = 0;
               for(var i = 0; i < 3; i = i + 1) { a = a + 1; }
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varA)), ExpressionValue.intValue(raw: 3))
  }
  
  func testCallNativeFunction() {
    let code = """
               clock();
               """
    XCTAssertNoThrow(try interpreter.interpret(code: code))
  }
  
  func testCallInvalidCallable() {
    let code = """
               "func"();
               """
    XCTAssertThrowsError(try interpreter.interpret(code: code))
  }
  
  func testDeclareFunction() {
    let funcName = Token(type: .IDENTIFIER, lexeme: "test", line: 1)
    let code = "fun test(a, b) { print 123; }"
    try! interpreter.interpret(code: code)
    let variableExpr = Expression.variable(name: funcName)
    guard let value = try? interpreter.visit(expression: variableExpr),
          case let .anyValue(raw) = value else {
      XCTFail()
      return
    }
    XCTAssertTrue(raw is Function)
  }
  
  func testCallDeclaredFunction() {
    let code = """
               fun test(a, b) { print 123; }
               test(1, 2);
               """
    XCTAssertNoThrow(try interpreter.interpret(code: code))
  }
  
  func testCallFunctionWithUnexceptArgumentsCount() {
    let code = """
               fun test() { print 123; }
               test(1, 2);
               """
    XCTAssertThrowsError(try interpreter.interpret(code: code))
  }
  
  func testCallFunctionRecursivly() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               var a = 0;
               fun test() {
                 a = a + 1;
                 if (a < 10) {
                   test();
                 }
               }
               test();
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varName)), ExpressionValue.intValue(raw: 10))
  }
  
  func testCallFunctionWithReturnValue() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               fun test() {
                 return "string";
               }
               var a = test();
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varName)), ExpressionValue.stringValue(raw: "string"))
  }
  
  func testCallFunctionWithReturnVoid() {
    let varName = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let code = """
               fun test() {
                 return;
               }
               var a = test();
               """
    try! interpreter.interpret(code: code)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varName)), ExpressionValue.anyValue(raw: ()))
  }
  
  func testLocalFunctionClosureCapture() {
    let code = """
               fun makeCounter() {
                 var i = 0;
                 fun count() {
                   i = i + 1;
                   return i;
                 }

                 return count;
               }

               var counter = makeCounter();
               var a = counter();
               var b = counter();
               """
    try! interpreter.interpret(code: code)
    let varA = Token(type: .IDENTIFIER, lexeme: "a", line: 1)
    let varB = Token(type: .IDENTIFIER, lexeme: "b", line: 1)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varA)), ExpressionValue.intValue(raw: 1))
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: varB)), ExpressionValue.intValue(raw: 2))
  }
  
  func testCreatClassInstance() {
    let code = """
               class A {
                 method() {}
               }

               var instance = A();
               """
    try! interpreter.interpret(code: code)
    let instanceToken = Token(type: .IDENTIFIER, lexeme: "instance", line: 1)
    let instance = try! interpreter.visit(expression: .variable(name: instanceToken))
    XCTAssertEqual(instance.description, "{instance A}")
  }
  
  func testGetUndefinedInstanceProperty() {
    let code = """
               class A {
                 method() {}
               }

               var prop = A().prop;
               """
    XCTAssertThrowsError(try interpreter.interpret(code: code))
  }
  
  func testSetAndGetInstanceProperty() {
    let code = """
               class A {
                 method() {}
               }
               var a = A();
               a.prop = 1;
               var prop = a.prop;
               """
    try! interpreter.interpret(code: code)
    let prop = Token(type: .IDENTIFIER, lexeme: "prop", line: 1)
    XCTAssertEqual(try! interpreter.visit(expression: .variable(name: prop)), ExpressionValue.intValue(raw: 1))
  }

}
