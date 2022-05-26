//
//  Class.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/25.
//

import Foundation

class Class {
  let name: String
  let methods: [String: Function]
  let initializer: Function?
  
  init(name: String, methods: [String: Function], initializer: Function? = nil) {
    self.name = name
    self.methods = methods
    self.initializer = initializer
  }
}

extension Class: CustomStringConvertible {
  var description: String {
    return "{class \(name)}"
  }
}

// class的构造器实现
extension Class: Callable {
  var arity: Int {
    return initializer?.arity ?? 0
  }
  
  func dynamicallyCall(withArguments args: [ExpressionValue]) throws -> ExpressionValue {
    let instance = Instance(class: self)
    try initializer?.bind(variable: "this", value: .anyValue(raw: instance)).dynamicallyCall(withArguments: args)
    return .anyValue(raw: instance)
  }
}
