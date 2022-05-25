//
//  Class.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/25.
//

import Foundation

class Class {
  let name: String
  
  init(name: String) {
    self.name = name
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
    return 0
  }
  
  func dynamicallyCall(withArguments args: [ExpressionValue]) throws -> ExpressionValue {
    return .anyValue(raw: Instance(class: self))
  }
}
