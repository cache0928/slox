//
//  AnyLiteral.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/2.
//

import Foundation

protocol AnyLiteral: CustomStringConvertible {
  
}

extension String: AnyLiteral {
  var description: String {
    return self
  }
}

extension Double: AnyLiteral {
  var description: String {
    return String(self)
  }
}

extension Bool: AnyLiteral {
  var description: String {
    return String(self)
  }
}

extension Int: AnyLiteral {
  var description: String {
    return String(self)
  }
}
