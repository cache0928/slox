//
//  StatementExecutor.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/18.
//

import Foundation

protocol StatementVisitor {
  func visit(statement: Statement) throws
}
