//
//  ExpressionEvaluator.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/13.
//

import Foundation

protocol ExpressionEvaluator {
  func evaluate(expression: Expression) throws -> ExpressionValue
}

extension ExpressionEvaluator {
  func evaluateUnary(op: Token, right: Expression) throws -> ExpressionValue {
    let rightValue = try evaluate(expression: right)
    switch op.type {
      case .MINUS:
        guard let result = -rightValue else {
          throw RuntimeError.operandError(token: op, message: "Operand must be a number.")
        }
        return result
      case .BANG:
        return !rightValue
      default:
        throw RuntimeError.operandError(token: op, message: "Unsupport unary operator.")
    }
  }
  
  func evaluateBinary(op: Token, left: Expression, right: Expression) throws -> ExpressionValue {
    func evaluateOp(leftValue: ExpressionValue,
                    rightValue: ExpressionValue,
                    `operator`: (ExpressionValue, ExpressionValue) -> ExpressionValue?) throws -> ExpressionValue  {
      guard let result = `operator`(leftValue, rightValue) else {
        throw RuntimeError.operandError(
          token: op,
          message: op.type == .PLUS ? "Operands must be two numbers or two strings." : "Operands must be two numbers."
        )
      }
      return result
    }
    
    let leftValue = try evaluate(expression: left)
    let rightValue = try evaluate(expression: right)
    switch op.type {
      case .PLUS:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: +)
      case .MINUS:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: -)
      case .STAR:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: *)
      case .SLASH:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: /)
      case .GREATER:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: >)
      case .GREATER_EQUAL:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: >=)
      case .LESS:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: <)
      case .LESS_EQUAL:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue, operator: <=)
      case .EQUAL_EQUAL:
        return leftValue === rightValue
      case .BANG_EQUAL:
        return leftValue !== rightValue
      default:
        throw RuntimeError.operandError(token: op, message: "Unsupport binary operator.")
    }
  }
}
