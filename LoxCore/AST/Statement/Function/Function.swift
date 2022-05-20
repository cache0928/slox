//
//  Function.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/19.
//

import Foundation

struct Function: Callable {
  let name: String
  let paramNames: [String]
  // 函数定义时候捕获的闭包环境
  let closure: Environment
  private let underly: ([ExpressionValue]) throws -> ExpressionValue

  init(name: String,
       paramNames: [String],
       closure: Environment,
       call: @escaping ([ExpressionValue]) throws -> ExpressionValue) {
    self.name = name
    self.paramNames = paramNames
    self.closure = closure
    self.underly = call
  }
  
  var arity: Int {
    return paramNames.count
  }
  
  func dynamicallyCall(withArguments args: [ExpressionValue]) throws -> ExpressionValue {
    return try underly(args)
  }
}
