//
//  File.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/3.
//

import Foundation

extension Expression {
  var evaluated: AnyValue {
    get throws {
      switch self {
        case .literal(let value):
          guard value != nil else {
            return AnyValue.nilValue
          }
          if let intValue = value as? Int {
            return AnyValue.intValue(raw: intValue)
          } else if let doubleValue = value as? Double {
            return AnyValue.doubleValue(raw: doubleValue)
          } else if let strValue = value as? String {
            return AnyValue.stringValue(raw: strValue)
          }
          return AnyValue.boolValue(raw: value as! Bool)
        case .grouping(let expression):
          return try expression.evaluated
        case .unary(let op, let right):
          return try evaluateUnary(op: op, right: right)
        case .binary(let left, let right, let op):
          return try evaluateBinary(op: op, left: left, right: right)
      }
    }
  }
  
  fileprivate func evaluateUnary(op: Token, right: Expression) throws -> AnyValue {
    let rightValue = try right.evaluated
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
  
  fileprivate func evaluateBinary(op: Token, left: Expression, right: Expression) throws -> AnyValue {
    
    func evaluateOp(leftValue: AnyValue,
                    rightValue: AnyValue,
                    `operator`: (AnyValue, AnyValue) -> AnyValue?,
                    errorMessage: String = "Operands must be two numbers.") throws -> AnyValue  {
      guard let result = `operator`(leftValue, rightValue) else {
        throw RuntimeError.operandError(
          token: op,
          message: errorMessage
        )
      }
      return result
    }
    
    let leftValue = try left.evaluated
    let rightValue = try right.evaluated
    switch op.type {
      case .PLUS:
        return try evaluateOp(leftValue: leftValue, rightValue: rightValue,
                              operator: +,
                              errorMessage: "Operands must be two numbers or two strings.")
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
