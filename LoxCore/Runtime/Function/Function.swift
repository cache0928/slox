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
  private let underly: ([ExpressionValue], Environment) throws -> ExpressionValue

  init(name: String,
       paramNames: [String],
       closure: Environment,
       call: @escaping ([ExpressionValue], Environment) throws -> ExpressionValue) {
    self.name = name
    self.paramNames = paramNames
    self.closure = closure
    self.underly = call
  }
  
  var arity: Int {
    return paramNames.count
  }
  
  @discardableResult
  func dynamicallyCall(withArguments args: [ExpressionValue]) throws -> ExpressionValue {
    return try underly(args, self.closure)
  }
}

extension Function {
  func bind(variable name: String, value: ExpressionValue) -> Function {
    let newEnv = Environment(enclosing: closure)
    newEnv.define(variableName: name, value: value)
    return Function(name: self.name,
                    paramNames: paramNames,
                    closure: newEnv,
                    call: underly)
  }
}
