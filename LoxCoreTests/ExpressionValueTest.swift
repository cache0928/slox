//
//  AnyValueTest.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/4.
//

import XCTest
@testable import LoxCore

class ExpressionValueTest: XCTestCase {
  
  func testValueRepresentByLiteral() {
    let int: ExpressionValue = 1
    let double: ExpressionValue = 1.0
    let string: ExpressionValue = "string"
    let bool: ExpressionValue = true
    let nilValue: ExpressionValue = nil
    
    XCTAssertEqual(int, ExpressionValue.intValue(raw: 1))
    XCTAssertEqual(double, ExpressionValue.doubleValue(raw: 1.0))
    XCTAssertEqual(string, ExpressionValue.stringValue(raw: "string"))
    XCTAssertEqual(bool, ExpressionValue.boolValue(raw: true))
    XCTAssertEqual(nilValue, ExpressionValue.nilValue)
  }
  
  func testTwoIntBinary() {
    let left: ExpressionValue = 1
    let right: ExpressionValue = 2
    
    XCTAssertEqual((left + right), ExpressionValue.intValue(raw: 3))
    XCTAssertEqual((left - right), ExpressionValue.intValue(raw: -1))
    XCTAssertEqual((left * right), ExpressionValue.intValue(raw: 2))
    XCTAssertEqual((left / right), ExpressionValue.intValue(raw: 0))
    XCTAssertEqual((left > right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left >= right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left < right), ExpressionValue.boolValue(raw: true))
    XCTAssertEqual((left <= right), ExpressionValue.boolValue(raw: true))
    XCTAssertEqual((left === right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left !== right), ExpressionValue.boolValue(raw: true))
  }
  
  func testTwoDoubleBinary() {
    let left: ExpressionValue = 1.0
    let right: ExpressionValue = 2.0
    
    XCTAssertEqual((left + right), ExpressionValue.doubleValue(raw: 3))
    XCTAssertEqual((left - right), ExpressionValue.doubleValue(raw: -1))
    XCTAssertEqual((left * right), ExpressionValue.doubleValue(raw: 2))
    XCTAssertEqual((left / right), ExpressionValue.doubleValue(raw: 0.5))
    XCTAssertEqual((left > right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left >= right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left < right), ExpressionValue.boolValue(raw: true))
    XCTAssertEqual((left <= right), ExpressionValue.boolValue(raw: true))
    XCTAssertEqual((left === right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left !== right), ExpressionValue.boolValue(raw: true))
  }
  
  func testIntAndDoubleBinary() {
    let left: ExpressionValue = 1
    let right: ExpressionValue = 2.0
    
    XCTAssertEqual((left + right), ExpressionValue.doubleValue(raw: 3))
    XCTAssertEqual((left - right), ExpressionValue.doubleValue(raw: -1))
    XCTAssertEqual((left * right), ExpressionValue.doubleValue(raw: 2))
    XCTAssertEqual((left / right), ExpressionValue.doubleValue(raw: 0.5))
    XCTAssertEqual((left > right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left >= right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left < right), ExpressionValue.boolValue(raw: true))
    XCTAssertEqual((left <= right), ExpressionValue.boolValue(raw: true))
    XCTAssertEqual((left === right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left !== right), ExpressionValue.boolValue(raw: true))
  }
  
  func testTwoStringBinary() {
    let left: ExpressionValue = "string1"
    let right: ExpressionValue = "string2"
    
    XCTAssertEqual(left + right, ExpressionValue(rawValue: "string1string2"))
  }
  
  func testInvalidBinaryOperand() {
    let left: ExpressionValue = "string1"
    let right: ExpressionValue = 1
    
    XCTAssertNil(left + right)
    XCTAssertNil(left - right)
    XCTAssertNil(left * right)
    XCTAssertNil(left / right)
    XCTAssertNil(left > right)
    XCTAssertNil(left >= right)
    XCTAssertNil(left < right)
    XCTAssertNil(left <= right)
    XCTAssertEqual((left === right), ExpressionValue.boolValue(raw: false))
    XCTAssertEqual((left !== right), ExpressionValue.boolValue(raw: true))
  }
  
  func testUnaryOperator() {
    let bool: ExpressionValue = true
    let int: ExpressionValue = 1
    let double: ExpressionValue = 2.0
    
    XCTAssertEqual(!bool, ExpressionValue.boolValue(raw: false))
    XCTAssertEqual(-int, ExpressionValue.intValue(raw: -1))
    XCTAssertEqual(-double, ExpressionValue.doubleValue(raw: -2))
    
    XCTAssertEqual(!int, ExpressionValue.boolValue(raw: false))
    XCTAssertEqual(!double, ExpressionValue.boolValue(raw: false))
    XCTAssertNil(-bool)
  }
  
  func testCompareOperator() {
    let bool: ExpressionValue = true
    let int: ExpressionValue = 1
    let double: ExpressionValue = 2.0
    let string: ExpressionValue = "3.0"
    let nilValue: ExpressionValue = nil
    
    XCTAssertEqual(int <= double, ExpressionValue.boolValue(raw: true))
    XCTAssertEqual(int >= ExpressionValue.doubleValue(raw: 0.5), ExpressionValue.boolValue(raw: true))
    XCTAssertNil(bool > int)
    XCTAssertNil(string > double)
    XCTAssertNil(string < bool)
    XCTAssertNil(nilValue < bool)
    XCTAssertNil(nilValue > string)
  }

}
