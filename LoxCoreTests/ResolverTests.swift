//
//  ResolverTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/24.
//

import XCTest
@testable import LoxCore

class ResolverTests: XCTestCase {
  let resolver = Resolver()
  
  func statements(from code: String) -> [Statement] {
    var scanner = Scanner(source: code)
    var parser = Parser(tokens: try! scanner.scanTokens())
    return try! parser.parse()
  }
  
  func testInvalidReturn() {
    let code = """
               var a = 1;
               return;
               """
    let statements = statements(from: code)
    XCTAssertThrowsError(try resolver.resolve(statements: statements))
  }
  
  func testRedeclarationVariableNotInGlobal() {
    let code = """
               {
                var a = 1;
                var a = 2;
               }
               """
    let statements = statements(from: code)
    XCTAssertThrowsError(try resolver.resolve(statements: statements))
  }
  
  func testBindingInGlobal() {
    let code = """
               var a = 1;
               a = 2;
               """
    let statements = statements(from: code)
    let bindings = try! resolver.resolve(statements: statements)
    XCTAssertTrue(bindings.isEmpty)
  }
  
  func testBindingInBlock() {
    let code = """
               var a = 1;
               {
                 a = 2;
                 var b = 3;
                 var c = 4;
                 b; // b -> 0
                 {
                   b = 5; // b -> 1
                   var d = b + c; // b -> 1, c -> 1
                   d = a; // d -> 0
                 }
               }
               """
    let statements = statements(from: code)
    let bindings = try! resolver.resolve(statements: statements)
    XCTAssertEqual(bindings.count, 5)
    XCTAssertEqual(bindings.values.elements, [0, 1, 1, 1, 0])
  }
  
  func testBindingInFunction() {
    let code = """
               var a = 1;
               fun test(a, b) {
                var c = a + 1; // a -> 1
                return c + b; // c -> 0, b -> 1
               }
               """
    let statements = statements(from: code)
    let bindings = try! resolver.resolve(statements: statements)
    XCTAssertEqual(bindings.count, 3)
    XCTAssertEqual(bindings.values.elements, [1, 0, 1])
  }
  
  func testBindingInWhile() {
    let code = """
               {
                 var a = 1;
                 while(a > 3) { // a -> 0
                   a = a + 1; // a -> 1, a -> 1
                 }
               }
               """
    let statements = statements(from: code)
    let bindings = try! resolver.resolve(statements: statements)
    XCTAssertEqual(bindings.count, 3)
    XCTAssertEqual(bindings.values.elements, [0, 1, 1])
  }
  
  func testBindingInFor() {
    let code = """
               {
                 var a = 1;
                 for(var i = 0; i < 3; i = i + 1) {
                   a = i + 1; // a -> 3, i -> 1
                 }
               }
               """
    let statements = statements(from: code)
    let bindings = try! resolver.resolve(statements: statements)
    XCTAssertEqual(bindings.count, 5)
    XCTAssertEqual(bindings.values.elements, [0, 2, 3, 1, 1])
  }
  
  func testBindingInIf() {
    let code = """
               {
                 var a = 1;
                 if (a > 1) { // -> 0
                   print a; // -> 1
                 } else {
                   print a + 1; // - > 1
                 }
               }
               """
    let statements = statements(from: code)
    let bindings = try! resolver.resolve(statements: statements)
    XCTAssertEqual(bindings.count, 3)
    XCTAssertEqual(bindings.values.elements, [0, 1, 1])
  }
  
}
