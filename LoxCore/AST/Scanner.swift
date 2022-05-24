//
//  Scanner.swift
//  slox
//
//  Created by 徐才超 on 2022/4/18.
//

import Foundation

public struct Scanner {
  private let source: String
  private var tokens: [Token] = []
  private var tokenStartIndex: String.Index
  private var currentScanIndex: String.Index
  private var line = 1
  
  public init(source: String) {
    self.source = source
    tokenStartIndex =  source.startIndex
    currentScanIndex = source.startIndex
  }
  
  public mutating func scanTokens() throws -> [Token]  {
    repeat {
      tokenStartIndex = currentScanIndex
      try scanToken()
    } while !isAtEnd
    tokens.append(Token(type: .EOF, lexeme: "", line: line, literal: nil))
    return tokens
  }
  
  private mutating func scanToken() throws {
    guard let c = advanceIndex() else {
      // 到达文件末尾
      return
    }
    switch c {
      case "(",")","{","}",",",".","-","+",";","*": addToken(type: TokenType(rawValue: String(c))!)
      case "!": addToken(type: match(expected: "=") ? TokenType(rawValue: "!=")! : TokenType(rawValue: "!")!)
      case "=": addToken(type: match(expected: "=") ? TokenType(rawValue: "==")! : TokenType(rawValue: "=")!)
      case "<": addToken(type: match(expected: "=") ? TokenType(rawValue: "<=")! : TokenType(rawValue: "<")!)
      case ">": addToken(type: match(expected: "=") ? TokenType(rawValue: ">=")! : TokenType(rawValue: ">")!)
      case "/":
        if (match(expected: "/")) {
          // 是注释的话直接消耗整行
          while currentCharacter != "\n" && !isAtEnd {
            advanceIndex()
          }
        } else if (match(expected: "*")) {
          try scanCStyleComments()
        } else {
          addToken(type: TokenType(rawValue: "/")!)
        }
      case "\"": try scanString()
      default:
        if c.isNewline {
          line += 1
        } else if c.isWhitespace {
          // 忽略空白
          break
        } else if c.isDigit {
          scanNumber()
        } else if c.isAlpha {
          scanIdentifier()
        } else {
          throw ScanError.unexpectedCharacter(line: line)
        }
    }
  }
  
  private mutating func match(expected: Character) -> Bool {
    guard !isAtEnd else {
      return false
    }
    if source[currentScanIndex] != expected {
      return false
    }
    advanceIndex()
    return true
  }
  
  @discardableResult
  private mutating func advanceIndex() -> Character? {
    guard !isAtEnd else {
      return nil
    }
    let c = source[currentScanIndex]
    currentScanIndex = source.index(after: currentScanIndex)
    return c
  }
  
  private mutating func scanString() throws {
    while currentCharacter != "\"" && !isAtEnd {
      if currentCharacter == "\n" {
        line += 1
      }
      advanceIndex()
    }
    // 扫描到底都没发现下一个引号
    guard !isAtEnd else {
      throw ScanError.unterminatedString(line: line)
    }
    // tokenStartIndex此时指向开始的引号，currentScanIndex指向闭合引号
    let str = String(source[source.index(after: tokenStartIndex)..<currentScanIndex])
    addToken(type: .STRING, literal: str)
    // 取出字面量后将指针移动至闭合引号的下一个字符
    advanceIndex()
  }
  
  private mutating func scanNumber() {
    while currentCharacter?.isDigit == true {
      advanceIndex()
    }
    // 小数
    if currentCharacter == "." && nextCharacter?.isDigit == true {
      // 移过小数点，开始寻找小数位
      advanceIndex()
      while currentCharacter?.isDigit == true {
        advanceIndex()
      }
    }
    if let value = Int(source[tokenStartIndex..<currentScanIndex]) {
      addToken(type: .INT, literal: value)
    } else {
      addToken(type: .DOUBLE, literal: Double(source[tokenStartIndex..<currentScanIndex]))
    }
  }
  
  private mutating func scanIdentifier() {
    while currentCharacter?.isAlphaNumberic == true {
      advanceIndex()
    }
    let str = String(source[tokenStartIndex ..< currentScanIndex])
    let tokenType = TokenType(rawValue: str) ?? .IDENTIFIER
    addToken(type: tokenType)
  }
  
  private mutating func scanCStyleComments() throws {
    while currentCharacter != "*" && !isAtEnd {
      if currentCharacter == "\n" {
        line += 1
      }
      advanceIndex()
    }
    guard !isAtEnd else {
      throw ScanError.unterminatedComment(line: line)
    }
    advanceIndex()
    if match(expected: "/") {
      return
    } else {
      try scanCStyleComments()
    }
  }
  
  private mutating func addToken(type: TokenType, literal: AnyLiteral? = nil) {
    let text = source[tokenStartIndex ..< currentScanIndex]
    tokens.append(Token(type: type, lexeme: String(text), line: line, literal: literal))
  }
  
  private var isAtEnd:  Bool  {
    return currentScanIndex >= source.endIndex
  }
  
  private var currentCharacter: Character? {
    guard !isAtEnd else {
      return nil
    }
    return source[currentScanIndex]
  }
  
  private var nextCharacter: Character? {
    guard currentScanIndex < source.index(before: source.endIndex) else {
      return nil
    }
    return source[source.index(after: currentScanIndex)]
  }
}
