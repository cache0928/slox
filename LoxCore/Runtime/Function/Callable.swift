//
//  LoxCallable.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/18.
//

import Foundation

@dynamicCallable
protocol Callable {
  var arity: Int { get }
  func dynamicallyCall(withArguments args: [ExpressionValue]) throws -> ExpressionValue
}

struct AnyCallable: Callable {
  func dynamicallyCall(withArguments args: [ExpressionValue]) throws -> ExpressionValue {
    try underly(args)
  }
  
  let arity: Int
  private let underly: ([ExpressionValue]) throws -> ExpressionValue
  
  init(arity: Int, _ call: @escaping ([ExpressionValue]) throws -> ExpressionValue) {
    self.arity = arity
    self.underly = call
  }
}
