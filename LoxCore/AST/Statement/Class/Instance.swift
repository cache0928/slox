//
//  Instance.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/25.
//

import Foundation

@dynamicMemberLookup
class Instance {
  let isa: Class
  var fileds: [String: ExpressionValue] = [:]
  
  init(`class`: Class) {
    self.isa = `class`
  }
  
  subscript(dynamicMember member: String) -> ExpressionValue? {
    get {
      if let filed = fileds[member] {
        return filed
      } else if let method = isa.methods[member] {
        let thisEnv = Environment(enclosing: method.closure)
        thisEnv.define(variableName: "this", value: .anyValue(raw: self))
        let methodWithThis = Function(name: method.name,
                                      paramNames: method.paramNames,
                                      closure: thisEnv,
                                      call: method.underly)
        return .anyValue(raw: methodWithThis)
      } else {
        return nil
      }
    }
    set {
      fileds[member] = newValue
    }
  }
}

extension Instance: CustomStringConvertible {
  var description: String {
    return "{instance \(isa.name)}"
  }
}
