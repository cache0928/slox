//
//  Instance.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/25.
//

import Foundation

@dynamicMemberLookup
class Instance {
  let `class`: Class
  var fileds: [String: ExpressionValue] = [:]
  
  init(`class`: Class) {
    self.class = `class`
  }
  
  subscript(dynamicMember member: String) -> ExpressionValue? {
    get {
      return fileds[member]
    }
    set {
      fileds[member] = newValue
    }
  }
}

extension Instance: CustomStringConvertible {
  var description: String {
    return "{instance \(`class`.name)}"
  }
}
