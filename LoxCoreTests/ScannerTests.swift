//
//  ScannerTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/4/18.
//

import XCTest
@testable import LoxCore

let keywords: [String: TokenType] = [
  "and": .AND,
  "class": .CLASS,
  "else": .ELSE,
  "false": .FALSE,
  "for": .FOR,
  "fun": .FUN,
  "if": .IF,
  "nil": .NIL,
  "or": .OR,
  "print": .PRINT,
  "return": .RETURN,
  "super": .SUPER,
  "this": .THIS,
  "true": .TRUE,
  "var": .VAR,
  "while": .WHILE
]

extension String {
  var tokenType: TokenType? {
    switch self {
      case "(":
        return .LEFT_PAREN
      case ")":
        return .RIGHT_PAREN
      case "{":
        return .LEFT_BRACE
      case "}":
        return .RIGHT_BRACE
      case ",":
        return .COMMA
      case ".":
        return .DOT
      case "-":
        return .MINUS
      case "+":
        return .PLUS
      case ";":
        return .SEMICOLON
      case "*":
        return .STAR
      case "=":
        return .EQUAL
      case "==":
        return .EQUAL_EQUAL
      case "!":
        return .BANG
      case "!=":
        return .BANG_EQUAL
      case "<":
        return .LESS
      case "<=":
        return .LESS_EQUAL
      case ">":
        return .GREATER
      case ">=":
        return .GREATER_EQUAL
      default:
        return keywords[self]
    }
  }
}

class ScannerTests: XCTestCase {
  
  override func setUpWithError() throws {
    try super.setUpWithError()
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
  }
  
  func getScanResult(source: String) throws -> [Token] {
    let scanner = Scanner(source: source)
    return try scanner.scanTokens()
  }
  
  func testSingleCharTokenType() {
    let singleChars = ["(", ")", "{", "}", ",", ".", "-", "+", ";", "*"]
    for char in singleChars {
      let result = try! getScanResult(source: char)
      XCTAssertEqual(char.tokenType, result.first?.type)
    }
  }
  
  func testOperatorTokenType() {
    let operators = ["=", "==", "!", "!=", "<", "<=", ">", ">="]
    for `operator` in operators {
      let result = try! getScanResult(source: `operator`)
      XCTAssertEqual(`operator`.tokenType, result.first?.type)
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
    XCTAssertEqual(result2.first?.literal as? Double, 1000)
  }
  
  func testKeywordsTokenType() {
    for entry in keywords {
      let result = try! getScanResult(source: entry.key)
      XCTAssertEqual(result.first?.type, entry.value)
    }
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

