//
//  AnyValueTest.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/4.
//

import XCTest
@testable import LoxCore

class AnyValueTest: XCTestCase {
  
  func testValueRepresentByLiteral() {
    let int: AnyValue = 1
    let double: AnyValue = 1.0
    let string: AnyValue = "string"
    let bool: AnyValue = true
    let nilValue: AnyValue = nil
    
    XCTAssertEqual(int, AnyValue.intValue(raw: 1))
    XCTAssertEqual(double, AnyValue.doubleValue(raw: 1.0))
    XCTAssertEqual(string, AnyValue.stringValue(raw: "string"))
    XCTAssertEqual(bool, AnyValue.boolValue(raw: true))
    XCTAssertEqual(nilValue, AnyValue.nilValue)
  }
  
  func testTwoIntBinary() {
    let left: AnyValue = 1
    let right: AnyValue = 2
    
    XCTAssertEqual((left + right), AnyValue.intValue(raw: 3))
    XCTAssertEqual((left - right), AnyValue.intValue(raw: -1))
    XCTAssertEqual((left * right), AnyValue.intValue(raw: 2))
    XCTAssertEqual((left / right), AnyValue.intValue(raw: 0))
    XCTAssertEqual((left > right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left >= right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left < right), AnyValue.boolValue(raw: true))
    XCTAssertEqual((left <= right), AnyValue.boolValue(raw: true))
    XCTAssertEqual((left === right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left !== right), AnyValue.boolValue(raw: true))
  }
  
  func testTwoDoubleBinary() {
    let left: AnyValue = 1.0
    let right: AnyValue = 2.0
    
    XCTAssertEqual((left + right), AnyValue.doubleValue(raw: 3))
    XCTAssertEqual((left - right), AnyValue.doubleValue(raw: -1))
    XCTAssertEqual((left * right), AnyValue.doubleValue(raw: 2))
    XCTAssertEqual((left / right), AnyValue.doubleValue(raw: 0.5))
    XCTAssertEqual((left > right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left >= right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left < right), AnyValue.boolValue(raw: true))
    XCTAssertEqual((left <= right), AnyValue.boolValue(raw: true))
    XCTAssertEqual((left === right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left !== right), AnyValue.boolValue(raw: true))
  }
  
  func testIntAndDoubleBinary() {
    let left: AnyValue = 1
    let right: AnyValue = 2.0
    
    XCTAssertEqual((left + right), AnyValue.doubleValue(raw: 3))
    XCTAssertEqual((left - right), AnyValue.doubleValue(raw: -1))
    XCTAssertEqual((left * right), AnyValue.doubleValue(raw: 2))
    XCTAssertEqual((left / right), AnyValue.doubleValue(raw: 0.5))
    XCTAssertEqual((left > right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left >= right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left < right), AnyValue.boolValue(raw: true))
    XCTAssertEqual((left <= right), AnyValue.boolValue(raw: true))
    XCTAssertEqual((left === right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left !== right), AnyValue.boolValue(raw: true))
  }
  
  func testTwoStringBinary() {
    let left: AnyValue = "string1"
    let right: AnyValue = "string2"
    
    XCTAssertEqual(left + right, AnyValue(rawValue: "string1string2"))
  }
  
  func testInvalidBinaryOperand() {
    let left: AnyValue = "string1"
    let right: AnyValue = 1
    
    XCTAssertNil(left + right)
    XCTAssertNil(left - right)
    XCTAssertNil(left * right)
    XCTAssertNil(left / right)
    XCTAssertNil(left > right)
    XCTAssertNil(left >= right)
    XCTAssertNil(left < right)
    XCTAssertNil(left <= right)
    XCTAssertEqual((left === right), AnyValue.boolValue(raw: false))
    XCTAssertEqual((left !== right), AnyValue.boolValue(raw: true))
  }
  
  func testUnaryOperator() {
    let bool: AnyValue = true
    let int: AnyValue = 1
    let double: AnyValue = 2.0
    
    XCTAssertEqual(!bool, AnyValue.boolValue(raw: false))
    XCTAssertEqual(-int, AnyValue.intValue(raw: -1))
    XCTAssertEqual(-double, AnyValue.doubleValue(raw: -2))
    
    XCTAssertEqual(!int, AnyValue.boolValue(raw: false))
    XCTAssertEqual(!double, AnyValue.boolValue(raw: false))
    XCTAssertNil(-bool)
  }
  
  func testCompareOperator() {
    let bool: AnyValue = true
    let int: AnyValue = 1
    let double: AnyValue = 2.0
    let string: AnyValue = "3.0"
    let nilValue: AnyValue = nil
    
    XCTAssertEqual(int <= double, AnyValue.boolValue(raw: true))
    XCTAssertEqual(int >= AnyValue.doubleValue(raw: 0.5), AnyValue.boolValue(raw: true))
    XCTAssertNil(bool > int)
    XCTAssertNil(string > double)
    XCTAssertNil(string < bool)
    XCTAssertNil(nilValue < bool)
    XCTAssertNil(nilValue > string)
  }

}
