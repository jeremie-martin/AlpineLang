import AST
import Parser
import Sema
import Foundation

public struct Interpreter {

  public init(debug: Bool = false) {
    self.debug = debug
    self.normalizer = Normalizer()
    self.symbolCreator = SymbolCreator(context: astContext)
    self.nameBinder = NameBinder(context: astContext)
    self.constraintCreator = ConstraintCreator(context: astContext)
    /* print("--------------------------------------------------") */
    /* for (symbol, function) in astContext.builtinScope.semantics { */
    /*   print("??????????", symbol.name, symbol.type, symbol.scope.id) */
    /* } */
    /* print("--------------------------------------------------") */
  }

  /// Whether or not the interpreter is in debug mode.
  public let debug: Bool
  /// The AST context of the interpreter.
  public let astContext = ASTContext()

  private var normalizer: Normalizer
  private let symbolCreator: SymbolCreator
  private let nameBinder: NameBinder
  private let constraintCreator: ConstraintCreator

  private var inputMod: String = ""
  private var replaceIn: [String: Value] = [:]

  // Load a module from a text input.
  @discardableResult
  public mutating func loadModule(fromString input: String) throws -> Module {
    // Parse the module into an untyped AST.
    let parser = try Parser(source: input)
    var module = try parser.parseModule()

    // Run semantic analysis to get the typed AST.
    module = try runSema(on: module) as! Module
    astContext.modules.append(module)

    return module
  }

  // Evaluate an expression from a text input, within the currently loaded context.
  public mutating func eval(string input: String, replace: [String: Value] = [:]) throws -> Value {
    /* let cpy = astContext.modules[0].copy() */
    // print("cpyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy")
    let dumper = ASTDumper(outputTo: Console.out)
    /* astContext.modules.removeFirst() */
    /*   astContext.modules.append(cpy) */
      /* print("POPOPOPOPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP") */
      /* print("POPOPOPOPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP") */
      /* print("POPOPOPOPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP") */
      /* print(cpy) */
      /* cpy.statements.forEach { print($0.module) } */
      /* astContext.modules[0].statements.forEach { print($0.module) } */
      /* print(astContext.modules[0]) */
      /* dumper.dump(ast: astContext.modules[0]) */
      /* print("POPOPOPOPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP") */
      /* print("POPOPOPOPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP") */
      /* print("POPOPOPOPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPPP") */
    /* try loadModule(fromString: inputMod) */
    
    // Parse the epxression into an untyped AST.
    let parser = try Parser(source: input)
    let expr = try parser.parseExpr()

    if(replace.count > 1000000) {
    // print("hmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm")
    replace.forEach { 
      switch $0.value {
      case .function(var f, let closure):
        /* f.symbol?.scope.symbols.forEach { print(" - ", $0.key, $0.value) } */
        for fff in (f.scope?.symbols)! {
          closure.forEach {
            for s in ($0.key.scope.symbols) {
              s.value.forEach {
                /* if f.symbol?.scope.symbols[$0.name] == nil { */
                /*   f.symbol?.scope.symbols[$0.name] = [] */
                /* } */
                /* f.symbol?.scope.symbols[$0.name]?.append($0) */
                if(fff.key == $0.name) {

                  /* print("aaaaaaaaaaaa", $0.name, fff.key, fff.value[0].hashValue, $0.hashValue, $0.type) */
                  /* assertionFailure() */
                }
              }
            }
            /* f.symbol?.scope.symbols[$0.key.name]? */
            /* .append($0.key) */
            /* f.symbol?.scope.symbols[$0.key.name].append($0.key) */
          }
        }
        /* print("aaa", f.scope?.symbols.count) */
        
        /* f.symbol?.scope.symbols.forEach { print(" - ", $0.key, $0.) } */
        break
      default:
        break
      }
    }
      /* assertionFailure() */
    }

    // Expressions can't be analyzed nor ran out-of-context, they must be nested in a module.
    var module = Module(statements: [expr], range: expr.range)
    // print("\n\n\n\n\n\n\n")
    // print("REPLAAAAAAAAAAAAAAAAAAAAAAAAAAAAACE")

    let rep = Replace(replace: replace, type: false)
    var ast = try rep.transform(module)
    replaceIn = replace

    // dumper.dump(ast: module)
    // print("REPLAAAAAAAAAAAAAAAAAAAAAAAAAAAAACE")
    // print("\n\n\n\n\n\n\n")
    if replace.count > 0 {
      /* assertionFailure() */
    }
    // Run semantic analysis to get the typed AST.
    let typedModule = try runSema(on: module, replace: replace) as! Module
    // print("---------------***************---------------********************")
    // dumper.dump(ast: module)
    // print("---------------***************---------------********************")

    /* let dumper = ASTDumper(outputTo: Console.out) */
    /* dumper.dump(ast: typedModule) */
    let ret = eval(expression: typedModule.statements[0] as! Expr, replaceContext: rep.evalContext.copy)
      switch ret {
      case .function(let f, let closure):
        break
      default:
        break
      }
    replaceIn = [:]
    return ret
  }

  public func eval(expression: Expr, replaceContext: EvaluationContext = [:]) -> Value {
    // Initialize an evaluation context with top-level symbols from built-in and loaded modules.
    let evalContext: EvaluationContext = [:]
    for (symbol, function) in astContext.builtinScope.semantics {
      evalContext[symbol] = .builtinFunction(function)
      // print(" /", symbol.name, symbol.type, symbol.scope.id)
    }

      /* for (symbol, function) in expression.module.functions { */
      /*   print("  +", symbol.name) */
      /*   evalContext[symbol] = .function(function, closure: [:]) */
      /* } */

    for module in astContext.modules {
      /* print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") */
      let dumper = ASTDumper(outputTo: Console.out)
      /* dumper.dump(ast: module) */
      for (symbol, function) in module.functions {
        // print("  -", symbol.name, symbol.scope.id, function.module)
        evalContext[symbol] = .function(function, closure: [:])
      }
    }

    evalContext.merge(replaceContext, uniquingKeysWith: { _, rhs in rhs })
    // Evaluate the expression.
    return eval(expression, in: evalContext)
  }

  private func eval(_ expr: Expr, in evalContext: EvaluationContext) -> Value {
    switch expr {
    case let e as Func          : return eval(e, in: evalContext)
    case let e as If            : return eval(e, in: evalContext)
    case let e as Match         : return eval(e, in: evalContext)
    case let e as Call          : return eval(e, in: evalContext)
    case let e as Tuple         : return eval(e, in: evalContext)
    case let e as Select        : return eval(e, in: evalContext)
    case let e as Ident         : return eval(e, in: evalContext)
    case let e as Scalar<Bool>  : return .bool(e.value)
    case let e as Scalar<Int>   : return .int(e.value)
    case let e as Scalar<Double>: return .real(e.value)
    case let e as Scalar<String>: return .string(e.value)
    default:
      // print("222222222222222")
      // print((expr as! Scalar<Int>).value)
      /* print(.i(expr as! Scalar<Int>).value)) */
      fatalError()
    }
  }
    /* for mod in astContext.modules { */
    /*   let dumper = ASTDumper(outputTo: Console.out) */
    /*   for (symbol, function) in mod.functions { */
    /*     print("  -", symbol.name, symbol.scope.id, function.module) */
    /*   } */
    /* } */
    /* print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") */
    /* print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") */
    /* print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") */
    /* print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") */

  public func eval(_ expr: Func, in evalContext: EvaluationContext) -> Value {
    var closure = evalContext.copy
    /* if let new = replaceIn[expr.name!] { */
    /*   switch new { */
    /*   case .function(let f, let cloclo): */
    /*     closure.merge(cloclo) { _, rhs in rhs } */
    /*   default: */
    /*     break */
    /*   } */
    /* } */
    let value = Value.function(expr, closure: closure)
    let mod = expr.module!
      let dumper = ASTDumper(outputTo: Console.out)
      for (symbol, function) in mod.functions {
        // print("  -", symbol.name, symbol.scope.id, function.module)
      }
    
    closure[expr.symbol!] = value
    /* let issou = eval(expr.body, in: closure) */
    
    return value
  }

  public func eval(_ expr: If, in evalContext: EvaluationContext) -> Value {
    // Evaluate the condition.
    let condition = eval(expr.condition, in: evalContext)
    guard case .bool(let value) = condition
      else { fatalError("non-boolean condition") }

    // Evaluate the branch, depending on the condition.
    return value
      ? eval(expr.thenExpr, in: evalContext)
      : eval(expr.elseExpr, in: evalContext)
  }

  public func eval(_ expr: Match, in evalContext: EvaluationContext) -> Value {
    // Evaluate the subject of the match.
    let subject = eval(expr.subject, in: evalContext)

    // Find the first pattern that matches the subject, along with its optional bindings.
    for matchCase in expr.cases {
      if let matchContext = match(subject, with: matchCase.pattern, in: evalContext) {
        return eval(matchCase.value, in: matchContext)
      }
    }

    // TODO: Sanitizing should make sure there's always at least one matching case for any subject,
    // or reject the program otherwise.
    fatalError("no matching pattern")
  }

  func match(_ subject: Value, with pattern: Expr, in evalContext: EvaluationContext)
    -> EvaluationContext?
  {
    switch pattern {
    case let binding as LetBinding:
      // TODO: Handle non-linear patterns.

      // Matching a value with a new binding obvioulsy succeed.
      let matchContext = evalContext.copy
      matchContext[binding.symbol!] = subject
      return matchContext

    case let tuplePattern as Tuple:
      guard case .tuple(_, let label, let elements) = subject
        else { return nil }
      guard (label == tuplePattern.label) && (elements.count == tuplePattern.elements.count)
        else { return nil }

      // Try merging each tuple element.
      var matchContext = evalContext.copy
      for (lhs, rhs) in zip(elements, tuplePattern.elements) {
        guard lhs.label == rhs.label
          else { return nil }
        guard let subMatchContext = match(lhs.value, with: rhs.value, in: matchContext)
          else { return nil }
        matchContext = subMatchContext
      }

      return matchContext

    default:
      // If the pattern is any expression other than a let binding or a tuple, we evaluate it and
      // use value equality to determine the result of the match.
      let value = eval(pattern, in: evalContext)

      // TODO: Semantic analysis should make sure there's an equality function between the subject
      // and the pattern, or reject the program otherwise. The current implementation reject all
      // values except native ones.
      switch (subject, value) {
      case (.bool(let lhs)  , .bool(let rhs))   : return lhs == rhs ? evalContext : nil
      case (.int(let lhs)   , .int(let rhs))    : return lhs == rhs ? evalContext : nil
      case (.real(let lhs)  , .real(let rhs))   : return lhs == rhs ? evalContext : nil
      case (.string(let lhs), .string(let rhs)) : return lhs == rhs ? evalContext : nil
      default:
        return nil
      }
    }
  }

  public func eval(_ expr: Call, in evalContext: EvaluationContext) -> Value {
    // Evaluate the callee and its arguments.
    /* let dumper = ASTDumper(outputTo: Console.out) */
    /* dumper.dump(ast: expr) */

    var callee =  eval(expr.callee, in: evalContext) //Value
    let arguments = expr.arguments.map { eval($0.value, in: evalContext) }
    switch expr.callee {
    case let n as Func:
      /* [> print("MDRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRr") <] */
      /* [> print(n.name) <] */
      /* [> evalContext.forEach { print(" - ", $0.key.name, $0.value, $0.key) } <] */
      /* [> print("XDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDd") <] */
      if let new = replaceIn[n.name!] {
        switch new {
        case .function(let f, let closure):
          /* [> [> expr.callee = f <] <] */
          /* [> [> let cont = evalContext.merging(closure, uniquingKeysWith: { _, rhs in rhs }) <] <] */
          let funcContext = evalContext.copy.merging(closure) { _, rhs in rhs }
          for (parameter, argument) in zip(f.signature.domain.elements, arguments) {
            if let name = parameter.name {
              let symbols = f.innerScope!.symbols[name]!
              assert(symbols.count == 1)
              funcContext[symbols[0]] = argument
            }
          }
          // Evaluate the function's body.
          // print("before eval", n.name)
          let ret = eval(f.body, in: funcContext)
          /* assertionFailure() */
          // print(ret)
          return ret

        default:
          callee = eval(expr.callee, in: evalContext)
          break
        }
      }
      else {
        callee = eval(expr.callee, in: evalContext)
      }
    default:
      callee = eval(expr.callee, in: evalContext)
      break
    }

    switch callee {
    case .builtinFunction(let function):
      // print("issou")
      let swiftArguments = arguments.compactMap { $0.swiftValue }
      // print("pouloulou")
      assert(swiftArguments.count == arguments.count)

      /* swiftArguments.forEach { print("-", $0, type(of: $0)) } */
      // print("function", type(of: function))
      /* dump(function) */
      // print("eval test", function([1 as Any, 2 as Any]))
      // print(function(swiftArguments))
      // print("sad")

      let aaa = Value(value: function(swiftArguments))!
      // print("test")
      return aaa

    case .function(let function, let closure):
      // Update the evaluation context with the function's arguments.
      let funcContext = evalContext.merging(closure) { _, rhs in rhs }
      for (parameter, argument) in zip(function.signature.domain.elements, arguments) {
        if let name = parameter.name {
          let symbols = function.innerScope!.symbols[name]!
          assert(symbols.count == 1)
          funcContext[symbols[0]] = argument
        }
      }

      // Evaluate the function's body.
      return eval(function.body, in: funcContext)

    default:
      fatalError("invalid expression: callee is not a function")
    }
  }

  public func eval(_ expr: Tuple, in evalContext: EvaluationContext) -> Value {
    // Evaluate the tuple's elements.
    let elements = expr.elements.map { (label: $0.label, value: eval($0.value, in: evalContext)) }
    /* expr.elements = elements */
    return .tuple(expr: expr, label: expr.label, elements: elements)
  }

  public func eval(_ expr: Select, in evalContext: EvaluationContext) -> Value {
    // Evaluate the owner.
    let owner = eval(expr.owner, in: evalContext)
    guard case .tuple(_, label: _, let elements) = owner
      else { fatalError("invalid expression: expected owner to be a tuple") }

    switch expr.ownee {
    case .label(let label):
      guard let element = elements.first(where: { $0.label == label })
        else { fatalError("\(owner) has no member named \(label)") }
      return element.value

    case .index(let index):
      guard index < elements.count
        else { fatalError("\(owner) has no \(index)-th member") }
      return elements[index].value
    }
  }

  public func eval(_ expr: Ident, in evalContext: EvaluationContext) -> Value {
    // print("&&&&&&&&&&&&", expr.name, expr.symbol?.name)


    /* evalContext.forEach { if($0.key.name == "eq") {print("  *", $0.key.name, $0.key.type, $0.key.scope.id, expr.symbol) } } */


    guard let sym = expr.symbol
      else { print("rip", expr.name, expr.symbol); fatalError("invalid expression: missing symbol") }

    /* let dumper = ASTDumper(outputTo: Console.out) */
    /* dumper.dump(ast: expr.module) */

    // Look for the identifier's symbol in the evaluation context.
    /*   if(sym.name == "bar"){ */
    /* evalContext.forEach { if($0.key.name == "op") {print("  *", $0.key.name, $0.key.type == sym.type, $0.key.scope.id, */
    /* sym.scope.id, sym.name, sym.hashValue, $0.key.hashValue, $0.key == sym );  } } */
    guard let value = evalContext[sym]
      else { fatalError("invalid expression: unbound identifier '\(expr.name)'") }
    // print("ééééééééééé")
    // print(value)
    return value
  }

  // Perform type inference on an untyped AST.
  private func runSema(on module: Module, replace: [String: Value] = [:]) throws -> Node {
    /* for (symbol, function) in astContext.builtinScope.semantics { */
    /*   print("///", symbol.name, symbol.type, symbol.scope.id) */
    /* } */
    /* var rep: [String: Expr] = [:] */
    /* for r in replace { */
    /*   rep[r.key] = r.value.copy() */
    /*   rep[r.key]!.module = module */
    /* } */
    
    let dumper = ASTDumper(outputTo: Console.out)
    // print("//////////////////////")
    var ast = try normalizer.transform(module)
    // print("\\\\\\\\\\\\\\\\\\\\\\\\")
    // dumper.dump(ast: module)
    if replace.count > 0 {
        /* assertionFailure() */
    }

    try symbolCreator.visit(module)
    try nameBinder.visit(module)
    try constraintCreator.visit(module)

    if debug {
      for constraint in astContext.typeConstraints {
        constraint.prettyPrint()
      }
      print()
    }
    // dumper.dump(ast: module)
    // print("PFIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIEX")
    if replace.count > 0 {
        /* assertionFailure() */
    }

    var solver = ConstraintSolver(constraints: astContext.typeConstraints, in: astContext)
    let result = solver.solve()

    switch result {
    case .success(let solution):
      let dispatcher = Dispatcher(context: astContext, solution: solution)
      ast = try dispatcher.transform(module) as! Module

    case .failure(let errors):
      // print("help wtf ???????")
      for error in errors {
        astContext.add(
          error: SAError.unsolvableConstraint(constraint: error.constraint, cause: error.cause),
          on: error.constraint.location.resolved)
      }
    }

    /* dumper.dump(ast: module) */
    /* if replace.count > 0 { */
    /*     assertionFailure() */
    /* } */
    // TODO
    /* guard astContext.errors.isEmpty */
    /*   else { throw InterpreterError.staticFailure(errors: astContext.errors) } */
    astContext.typeConstraints.removeAll()
    return ast
  }

}
