# slox

**Lox**解释器的Swift实现版本

这个项目包含了一个**Lox**解释器的Swift版本实现

**Lox**是一门迷你编程语言，来自于[Bob Nystrom](https://twitter.com/munificentbob)写的教程[Crafting Interpreters](http://www.craftinginterpreters.com)

编程原理是计算机科学中举足轻重的一部分，也是自认为我基础最薄弱的一个环节。动手做应该是学习某项知识最重要的环节。

Swift是我最喜欢的编程语言，没有之一。

# 实现

## 实现过程

- [ ] 4.  [**Scanning**](http://www.craftinginterpreters.com/scanning.html)

- [ ] 5.  [**Representing Code**](http://www.craftinginterpreters.com/representing-code.html)

- [ ] 6. [**Parsing Expressions**](http://www.craftinginterpreters.com/parsing-expressions.html) 

- [ ] 7. [**Evaluating Expressions**](http://www.craftinginterpreters.com/evaluating-expressions.html)

- [ ] 8. [**Statements and State**](http://www.craftinginterpreters.com/statements-and-state.html)

- [ ] 9. [**Control Flow**](http://www.craftinginterpreters.com/control-flow.html)

- [ ] 10. [**Functions**](http://www.craftinginterpreters.com/functions.html)

- [ ] 11. [**Resolving and Binding**](http://www.craftinginterpreters.com/resolving-and-binding.html)

- [ ] 12. [**Classes**](http://www.craftinginterpreters.com/classes.html)

- [ ] 13. [**Inheritance**](http://www.craftinginterpreters.com/inheritance.html)

# 测试

我尽量使用TDD的思想来开发每个阶段，所以Xcode工程中包含了使用`XCTest`实现的单元测试文件

# 工程结构

使用 [SPM](https://github.com/apple/swift-package-manager/) 来管理frameworks、依赖文件

解释器的主体实现包含在一个framework中，通过一个简单的CLI程序使用该framework来运行解释器

- slox: 可执行文件，用于在CLI中直接运行解释器
- LoxCore: 包含**Lox**核心实现的Swift framework
