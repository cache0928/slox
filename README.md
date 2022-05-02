# slox

**Lox**解释器的Swift实现版本

**Lox**是一门迷你编程语言，来自于[Bob Nystrom](https://twitter.com/munificentbob)写的编译器教程[Crafting Interpreters](http://www.craftinginterpreters.com)

编程原理是计算机科学中举足轻重的一部分，动手做应该是学习某项知识最重要的环节。

## 实现

我会尽量**参照书中所示的Java代码结构来实现**

但是Swift本身有太多优秀和新奇的特点，比如`guard`、`Optional`、`POP`等，我也会使用这些Swift独占特性，但整体的结构和逻辑应该和书本上的并无太大差异

### To-Do

- [x] 4.  [**Scanning**](http://www.craftinginterpreters.com/scanning.html)
  - [x] Challenge 4: C-style /* ... */ block comments.

- [x] 5.  [**Representing Code**](http://www.craftinginterpreters.com/representing-code.html)
  - [ ] Challenge 3: AST Printer In Reverse Polish Notation.
  - [ ] GenerateAst tool
  
- [x] 6. [**Parsing Expressions**](http://www.craftinginterpreters.com/parsing-expressions.html) 
  - [ ] Helper method for parsing left-associative series of binary operators. *Swift can't pass variadic arguments between functions (no array splatting), so it's a little bit hugly.*
  - [ ] Challenge 1: Add prefix and postfix ++ and -- operators.
  - [ ] Challenge 2: Add support for the C-style conditional or “ternary” operator `?:`
  - [ ] Challenge 3: Add error productions to handle each binary operator appearing without a left-hand operand.

- [ ] 7. [**Evaluating Expressions**](http://www.craftinginterpreters.com/evaluating-expressions.html)
  - [ ] Challenge 1: Allowing comparisons on types other than numbers could be useful.
  - [ ] Challenge 2: Many languages define + such that if either operand is a string, the other is converted to a string and the results are then concatenated.
  - [ ] Challenge 3: Change the implementation in visitBinary() to detect and report a runtime error when dividing by 0. 

- [ ] 8. [**Statements and State**](http://www.craftinginterpreters.com/statements-and-state.html)
  - [ ] Challenge 1: Add support to the REPL to let users type in both statements and expressions.
  - [ ] Challenge 2: Make it a runtime error to access a variable that has not been initialized or assigned to
  
- [ ] 9. [**Control Flow**](http://www.craftinginterpreters.com/control-flow.html)
  - [ ] Challenge 3: Add support for break statements.
  
- [ ] 10. [**Functions**](http://www.craftinginterpreters.com/functions.html)
  - [ ] Challenge 2: Add anonymous function (lambdas) syntax.
  
- [ ] 11. [**Resolving and Binding**](http://www.craftinginterpreters.com/resolving-and-binding.html)
  - [ ] Challenge 3: Extend the resolver to report an error if a local variable is never used.
  - [ ] Challenge 4: Store local variables in an array and look them up by index.
  
- [ ] 12. [**Classes**](http://www.craftinginterpreters.com/classes.html)
  - [ ] Challenge 1: Add class methods.
  - [ ] Challenge 2: Support getter methods.
  
- [ ] 13. [**Inheritance**](http://www.craftinginterpreters.com/inheritance.html)
  - [ ] Challenge 1: Multiple inheritance. *Nothing to implement...?*
  - [ ] Challenge 2: Reverse method lookup order in class hierarchy.

## 测试

我尽量使用TDD的思想来开发每个阶段，所以Xcode工程中包含了使用`XCTest`实现的单元测试文件。

## 工程结构

使用 [SPM](https://github.com/apple/swift-package-manager/) 来管理frameworks、依赖文件

解释器的主体实现包含在一个framework中，通过一个简单的CLI程序使用该framework来运行解释器

- slox: 可执行文件，用于在CLI中直接运行解释器
- LoxCore: 包含**Lox**核心实现的Swift framework
