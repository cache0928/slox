//
//  ExpressionEvaluator.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/13.
//

import Foundation

protocol ExpressionVisitor {
  associatedtype ReturnType
  func visit(expression: Expression) throws -> ReturnType
}
