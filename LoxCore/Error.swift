//
//  Error.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/4/18.
//

import Foundation

public enum LoxError: Error, CustomStringConvertible {

  case unexpectedCharacter(line: Int, message: String)
  case unterminatedString(line: Int, message: String)
  case unterminatedComment(line: Int, message: String)
  
  public var description: String {
    switch self {
      case .unexpectedCharacter(let line, let message),
           .unterminatedString(let line, let message),
           .unterminatedComment(let line, let message):
        return "[line \(line)] Error: \(message)"
    }
  }
}
