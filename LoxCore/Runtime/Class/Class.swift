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
  let superclass: Class?
  
  init(name: String, methods: [String: Function], initializer: Function? = nil, superclass: Class?) {
    self.name = name
    self.methods = methods
    self.initializer = initializer
    self.superclass = superclass
  }
  
  func find(method name: String) -> Function? {
    guard methods.keys.contains(name) else {
      return superclass?.find(method: name)
    }
    return methods[name]
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
    return initializer?.arity ?? superclass?.arity ?? 0
  }
  
  func dynamicallyCall(withArguments args: [ExpressionValue]) throws -> ExpressionValue {
    let instance = Instance(class: self)
    if let initializer = initializer {
      var real = initializer
      if let superclass = superclass {
        real = real.bind(variable: "super", value: .anyValue(raw: superclass))
      }
      try real
        .bind(variable: "this", value: .anyValue(raw: instance))
        .dynamicallyCall(withArguments: args)
    } else if let initializer = superclass?.initializer {
      var real = initializer
      if let grandclass = superclass?.superclass {
        real = real.bind(variable: "super", value: .anyValue(raw: grandclass))
      }
      try real
        .bind(variable: "this", value: .anyValue(raw: instance))
        .dynamicallyCall(withArguments: args)
    }
    return .anyValue(raw: instance)
  }
}
