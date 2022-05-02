//
//  ScannerTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/4/18.
//

import XCTest
@testable import LoxCore

class ScannerTests: XCTestCase {
  
  override func setUpWithError() throws {
    try super.setUpWithError()
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
  }
  
  func getScanResult(source: String) throws -> [Token] {
    var scanner = Scanner(source: source)
    return try scanner.scanTokens()
  }
  
  func testSingleCharTokenType() {
    let singleChars = ["(", ")", "{", "}", ",", ".", "-", "+", ";", "*"]
    for char in singleChars {
      let result = try! getScanResult(source: char)
      XCTAssertEqual(TokenType(rawValue: char)!, result.first?.type)
    }
  }
  
  func testOperatorTokenType() {
    let operators = ["=", "==", "!", "!=", "<", "<=", ">", ">="]
    for `operator` in operators {
      let result = try! getScanResult(source: `operator`)
      XCTAssertEqual(TokenType(rawValue: `operator`), result.first?.type)
    }
  }
  
  func testSlashTokenType() {
    let result = try! getScanResult(source: "/")
    XCTAssertEqual(result.first?.type, .SLASH)
  }
  
  func testDiscardComents() {
    let result1 = try! getScanResult(source: "//comments\n")
    XCTAssertEqual(result1.first?.type, .EOF)
    let result2 = try! getScanResult(source: "//comments")
    XCTAssertEqual(result2.first?.type, .EOF)
  }
  
  func testIgnoreWhitespace() {
    let whitespaces = [" ", "\r", "\t"]
    for char in whitespaces {
      let result = try! getScanResult(source: char)
      XCTAssertEqual(.EOF, result.first?.type)
    }
  }
  
  func testLineisIncreased() {
    let result = try! getScanResult(source: "\n")
    XCTAssertEqual(result.first?.line, 2)
  }
  
  func testStringLiterals() {
    let result = try! getScanResult(source: "\"string\"")
    XCTAssertEqual(result.first?.type, .STRING)
    XCTAssertEqual(result.first?.literal as? String, "string")
  }
  
  func testUnterminatedString() {
    XCTAssertThrowsError(try getScanResult(source: "\"string\n"))
  }
  
  func testNumberLiterals() {
    let result1 = try! getScanResult(source: "1234.56")
    XCTAssertEqual(result1.first?.type, .NUMBER)
    XCTAssertEqual(result1.first?.literal as? Double, 1234.56)
    let result2 = try! getScanResult(source: "1000")
    XCTAssertEqual(result2.first?.type, .NUMBER)
    XCTAssertEqual(result2.first?.literal as? Int, 1000)
  }
  
  func testScanIndentifiers() {
    let result = try! getScanResult(source: "var tmp = 1000")
    XCTAssertEqual(result.map{$0.type}, [.VAR, .IDENTIFIER, .EQUAL, .NUMBER, .EOF])
  }
  
  func testCStyleComments() {
    let result = try! getScanResult(source: "/*\n***some comments***\n*/")
    XCTAssertEqual(.EOF, result.first?.type)
    XCTAssertEqual(3, result.first?.line)
    XCTAssertThrowsError(try getScanResult(source: "/*\nsome comments\n*"))
  }
}

