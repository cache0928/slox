//
//  Count.swift
//  slox
//
//  Created by 徐才超 on 2022/4/11.
//

import Foundation
import ArgumentParser

@main
struct Lox: ParsableCommand {
  
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
      run(source: line)
      print("> ", terminator: "")
    }
  }
  
  private func runFile(path: String) {
    let url = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
    do {
      let data = try Data(contentsOf: url)
      if let source = String(data: data, encoding: .utf8) {
        run(source: source)
      }
    } catch {
      print("File Not Exist")
    }
    
  }

  private func run(source: String) {
    print(source)
  }
  
}
