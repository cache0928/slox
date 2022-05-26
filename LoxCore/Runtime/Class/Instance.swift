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
      } else if let method = isa.find(method: member) {
        var realMethod = method
        // 注入super
        if let superclass = isa.superclass {
          realMethod = realMethod.bind(variable: "super", value: .anyValue(raw: superclass))
        }
        // 注入this
        realMethod = realMethod.bind(variable: "this", value: .anyValue(raw: self))
        return .anyValue(raw: realMethod)
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
