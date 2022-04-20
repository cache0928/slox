//
//  main.swift
//  slox
//
//  Created by 徐才超 on 2022/4/18.
//

import Foundation
import ArgumentParser
import LoxCore

@main
struct SLox: ParsableCommand {
  @Option(help: "Lox Source File")
  var sourceFile: String?
  
  mutating func run() throws {
    guard let path = sourceFile else {
      runPrompt()
      return
    }
    runFile(path: path)
  }
  
  private func runPrompt() {
    print("> ", terminator: "")
    while let line = readLine() {
      do {
        try run(source: line)
      } catch {
        print(error)
      }
      print("> ", terminator: "")
    }
  }
  
  private func runFile(path: String) {
    let filePath = (path as NSString).expandingTildeInPath
    guard FileManager.default.fileExists(atPath: filePath) else {
      print("Error: File Not Exist")
      SLox.exit(withError: ExitCode(66))
    }
    do {
      let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
      if let source = String(data: data, encoding: .utf8) {
        try run(source: source)
      }
    } catch {
      print(error)
      SLox.exit(withError: ExitCode(65))
    }
  }
  
  private func run(source: String) throws {
    let scanner = LoxCore.Scanner(source: source)
    print(try scanner.scanTokens())
  }
}

