//
//  StatementsTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/7.
//

import XCTest
@testable import LoxCore

class ParseStatementsTests: XCTestCase {
  func testParseExpressionStatements() {
    let code = """
               1 - 2;
               true;
               "str1" + "str2";
               1 + ( 2 + 3 );
               """
    let returnValues: [ExpressionValue] = [-1, true, "str1str2", 6]
    let interpreter = try! Interpreter(source: code)
    for (stmt, value) in zip(interpreter, returnValues) {
      switch stmt {
        case.success(let result):
          XCTAssertEqual(result, value)
        case .failure(_):
          XCTFail()
      }
    }
  }
  
  func testStatementExceptSemicon() {
    let code = "1 + 2"
    XCTAssertThrowsError(try Interpreter(source: code))
  }
}
