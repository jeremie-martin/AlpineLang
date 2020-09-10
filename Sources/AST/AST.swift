/// Common interface for all AST nodes.
///
/// An Abstract Syntax Tree (AST) is a tree representation of a source code. Each node represents a
/// particular construction (e.g. a variable declaration), with each child representing a sub-
/// construction (e.g. the name of the variable being declared). The term "abstract" denotes the
/// fact that concrete syntactic details such as spaces and line returns are *abstracted* away.
import Foundation

public class Node: Equatable {
  // Lifecycle

  fileprivate init(module: Module?, range: SourceRange) {
    self.module = module
    self.range = range
  }

  // Public

  /// The module that contains the node.
  public var module: Module!
  /// Stores the ranges in the source file of the concrete syntax this node represents.
  public var range: SourceRange

  public static func == (lhs: Node, rhs: Node) -> Bool {
    lhs === rhs
  }

  public func copy() -> Node {
    // print("AST: Node", self.module)
    Node(module: module.copy(), range: range.copy())
    // print("AST: Node 2", self.module)
  }
}

/// An Alpine module.
///
/// This node represents an Alpine module (i.e. the semantics definition of a net).
public final class Module: Node {
  // Lifecycle

  public init(statements: [Node], range: SourceRange) {
    self.statements = statements
    super.init(module: nil, range: range)
    module = self
  }

  // Public

  /// Stores the statements of the module.
  public var statements: [Node]
  /// The identifier of the module.
  public var id: String?
  /// The scope delimited by the module.
  public var innerScope: Scope?

  /// The top-level function declarations.
  public var functions: [Symbol: Func] {
    let symbolsAndNodes = statements
      .compactMap { node in node as? Func }
      .compactMap { node in node.symbol.map { sym in (sym, node) } }
    return Dictionary(uniqueKeysWithValues: symbolsAndNodes)
  }

  override public func copy() -> Module {
    // print("AST: Module", self.module)
    /* self.statements.forEach { print($0.module) } */
    // print("AST: Module 2", self.module)
    let mod = Module(statements: [], range: range.copy())
    // print("AST: Module 3", self.module)
    mod.statements = try statements.map { $0.module = mod
      return $0.copy()
    }
    // print("AST: Module 4", self.module)
    try statements.forEach { $0.module = self }
    // print("AST: Module 5", self.module)

    /* let mod = Module(statements: try self.statements.map { $0.copy() }, range: self.range.copy()) */
    mod.id = (id != nil) ? String(id!) : nil
    mod.innerScope = innerScope?.copy()
    return mod
  }
}

/// A function declaration.
public final class Func: Expr {
  // Lifecycle

  public init(
    name: String?,
    signature: FuncSign,
    body: Expr,
    module: Module,
    range: SourceRange,
    idContext: Int = -1
  ) {
    self.name = name
    self.signature = signature
    self.body = body
    self.idContext = idContext
    super.init(module: module, range: range)
  }

  // Public

  public var idContext: Int

  /// The (optional) name of the function.
  public var name: String?
  /// The signature of the function.
  public var signature: FuncSign
  /// The body of the function.
  public var body: Expr

  /// The scope delimited by the function.
  public var innerScope: Scope?

  /// The symbol associated with the function.
  public var symbol: Symbol? {
    didSet {
      type = symbol?.type
    }
  }

  /// The scope in which the function is defined.
  public var scope: Scope? { symbol?.scope }

  override public func copy() -> Func {
    // print("AST: Func 1", self.module)
    let n = (name != nil) ? String(name!) : nil
    // print("AST: Func 2", self.module)
    var f = Func(
      name: n,
      signature: signature.copy(),
      body: body.copy(),
      module: module,
      range: range.copy()
    )
    // print("AST: Func 3", self.module)
    f.type = type?.copy()
    f.symbol = symbol?.copy(scope: symbol?.scope.copy())
    f.innerScope = innerScope?.copy()
    // print("AST: Func 6", self.module)
    return f
  }

  public func cpy() -> Func {
    var f = Func(
      name: name,
      signature: signature,
      body: body,
      module: module,
      range: range
    )
    f.type = type
    f.symbol = symbol
    f.innerScope = innerScope
    return f
  }
}

/// A type alias declaration.
public final class TypeAlias: Node {
  // Lifecycle

  public init(name: String, signature: TypeSign, module: Module, range: SourceRange) {
    self.name = name
    self.signature = signature
    super.init(module: module, range: range)
  }

  // Public

  /// The name of the alias.
  public var name: String
  /// The signature of the alias.
  public var signature: TypeSign
  /// The symbol associated with the type alias.
  public var symbol: Symbol?

  /// The scope in which the alias is defined.
  public var scope: Scope? { symbol?.scope }

  override public func copy() -> TypeAlias {
    // print("AST: TypeAlias", self.module)
    var e = TypeAlias(
      name: String(name),
      signature: signature.copy(),
      module: module,
      range: range.copy()
    )
    // print("AST: TypeAlias 2", self.module)
    let fff = symbol?.scope.copy()
    // print("AST: TypeAlias 3", self.module)
    e.symbol = symbol?.copy(scope: fff)
    // print("AST: TypeAlias 4", self.module)
    // print("hahahahaha")
    // print("AST: TypeAlias 5", self.module)
    /* e.scope?.symbols.forEach { print("Symbol:", $0.key, $0.value); $0.value.forEach { print("  val:", $0.scope, $0.scope.id, $0.type)} } */
    // print("AST: TypeAlias 6", self.module)
    // print("hrlooo")
    // print("AST: TypeAlias 7", self.module)
    // print(self.symbol?.scope)
    // print(e.symbol?.scope)
    return e
  }
}

/// Base class for nodes representing a type signature.
public class TypeSign: Node {
  /// The type of the signature.
  public var type: Metatype?

  override public func copy() -> TypeSign {
    // print("AST: TypeSign", self.module)
    var e = TypeSign(module: module, range: range.copy())
    // print("AST: TypeSign 2", self.module)
    e.type = type?.copy()
    // print("AST: TypeSign 3", self.module)
    return e
    // print("AST: TypeSign 4", self.module)
  }
}

/// A type identifier.
public final class TypeIdent: TypeSign {
  // Lifecycle

  public init(name: String, module: Module, range: SourceRange) {
    self.name = name
    super.init(module: module, range: range)
  }

  // Public

  /// The name of the type.
  public var name: String
  /// The scope in which the type identifier's defined.
  public var scope: Scope?
  /// The symbol associated with the name of this type identifier.
  public var symbol: Symbol?

  override public func copy() -> TypeIdent {
    // print("AST: TypeIdent", self.module)
    var e = TypeIdent(name: String(name), module: module, range: range.copy())
    // print("AST: TypeIdent 2", self.module)
    e.scope = scope?.copy()
    // print("AST: TypeIdent 3", self.module)
    e.symbol = symbol?.copy(scope: e.scope)
    // print("AST: TypeIdent 4", self.module)
    e.type = type?.copy()
    // print("AST: TypeIdent 5", self.module)
    return e
    // print("AST: TypeIdent 6", self.module)
  }
}

/// A function type signature.
public final class FuncSign: TypeSign {
  // Lifecycle

  public init(
    domain: TupleSign,
    codomain: TypeSign,
    module: Module,
    range: SourceRange
  ) {
    self.domain = domain
    self.codomain = codomain
    super.init(module: module, range: range)
  }

  // Public

  /// The domain of the function.
  public var domain: TupleSign
  /// The codomain of the function.
  public var codomain: TypeSign

  override public func copy() -> FuncSign {
    // print("AST: FuncSign", self.module)
    var e = FuncSign(
      domain: domain.copy(),
      codomain: codomain.copy(),
      module: module,
      range: range.copy()
    )
    // print("AST: FuncSign 2", self.module)
    e.type = type?.copy()
    // print("AST: FuncSign 3", self.module)
    return e
    // print("AST: FuncSign 4", self.module)
  }
}

/// A tuple type signature.
public final class TupleSign: TypeSign {
  // Lifecycle

  public init(
    label: String?,
    elements: [TupleSignElem],
    module: Module,
    range: SourceRange
  ) {
    self.label = label
    self.elements = elements
    super.init(module: module, range: range)
  }

  // Public

  /// The label of the tuple signature.
  public var label: String?
  /// The elements of the tuple signature.
  public var elements: [TupleSignElem]

  override public func copy() -> TupleSign {
    // print("AST: TupleSign", self.module)
    let l = (label != nil) ? String(label!) : nil
    // print("AST: TupleSign 2", self.module)
    var e = TupleSign(
      label: l,
      elements: try elements.map { $0.copy() },
      module: module,
      range: range.copy()
    )
    // print("AST: TupleSign 3", self.module)
    // print("hhh2", self.type, self.type?.type)
    // print("AST: TupleSign 4", self.module)
    e.type = type?.copy()
    // print("AST: TupleSign 5", self.module)
    return e
    // print("AST: TupleSign 6", self.module)
  }
}

/// A tuple element signature.
public final class TupleSignElem: Node {
  // Lifecycle

  public init(
    label: String?,
    name: String?,
    signature: TypeSign,
    module: Module,
    range: SourceRange
  ) {
    self.label = label
    self.name = name
    self.signature = signature
    super.init(module: module, range: range)
  }

  // Public

  /// The label of the tuple element.
  public var label: String?
  /// The name of the tuple element (for function domains only).
  public var name: String?
  /// The signature of the tuple element.
  public var signature: TypeSign

  override public func copy() -> TupleSignElem {
    // print("AST: TupleSignElem", self.module)
    let l = (label != nil) ? String(label!) : nil
    // print("AST: TupleSignElem 2", self.module)
    let n = (name != nil) ? String(name!) : nil
    // print("AST: TupleSignElem 3", self.module)

    return TupleSignElem(
      label: l,
      name: n,
      signature: signature.copy(),
      module: module,
      range: range.copy()
    )
  }
}

/// A union signature.
public final class UnionSign: TypeSign {
  // Lifecycle

  public init(cases: [TypeSign], module: Module, range: SourceRange) {
    self.cases = cases
    super.init(module: module, range: range)
  }

  // Public

  /// The cases of the union.
  public var cases: [TypeSign]

  override public func copy() -> UnionSign {
    // print("AST: UnionSign", self.module)
    var e = UnionSign(
      cases: try cases.map { $0.copy() },
      module: module,
      range: range.copy()
    )
    // print("AST: UnionSign 2", self.module)
    e.type = type?.copy()
    // print("AST: UnionSign 3", self.module)
    return e
    // print("AST: UnionSign 4", self.module)
  }
}

/// Base class for node representing an expression.
public class Expr: Node {
  /// The type of the expression.
  public var type: TypeBase?

  override public func copy() -> Expr {
    // print("AST: Expr", self.module)
    var e = Expr(module: module, range: range.copy())
    // print("AST: Expr 2", self.module)
    e.type = (type != nil) ? type?.copy() : nil
    // print("AST: Expr 3", self.module)
    return e
    // print("AST: Expr 4", self.module)
  }
}

/// A conditional expression.
public final class If: Expr {
  // Lifecycle

  public init(
    condition: Expr,
    thenExpr: Expr,
    elseExpr: Expr,
    module: Module,
    range: SourceRange
  ) {
    self.condition = condition
    self.thenExpr = thenExpr
    self.elseExpr = elseExpr
    super.init(module: module, range: range)
  }

  // Public

  /// The condition of the expression.
  public var condition: Expr
  /// The expression to evaluate if the condition is statisfied.
  public var thenExpr: Expr
  /// The expression to evaluate if the condition isn't statisfied.
  public var elseExpr: Expr

  /// The scope delimited by the then branch.
  public var thenScope: Scope?
  /// The scope delimited by the else branch.
  public var elseScope: Scope?

  override public func copy() -> If {
    // print("AST: If", self.module)
    var e = If(
      condition: condition.copy(),
      thenExpr: thenExpr.copy(),
      elseExpr: elseExpr.copy(),
      module: module,
      range: range.copy()
    )
    // print("AST: If 2", self.module)
    e.type = type?.copy()
    // print("AST: If 3", self.module)
    return e
    // print("AST: If 4", self.module)
  }
}

/// A match expression.
public final class Match: Expr {
  // Lifecycle

  public init(subject: Expr, cases: [MatchCase], module: Module, range: SourceRange) {
    self.subject = subject
    self.cases = cases
    super.init(module: module, range: range)
  }

  // Public

  /// The subject of the match.
  public var subject: Expr
  /// The case of the match.
  public var cases: [MatchCase]

  override public func copy() -> Match {
    // print("AST: Match", self.module)
    var e = Match(
      subject: subject.copy(),
      cases: cases.map { $0.copy() },
      module: module,
      range: range.copy()
    )
    // print("AST: Match 2", self.module)
    e.type = type?.copy()
    // print("AST: Match 3", self.module)
    return e
  }
}

/// A match case.
public final class MatchCase: Node {
  // Lifecycle

  public init(pattern: Expr, value: Expr, module: Module, range: SourceRange) {
    self.pattern = pattern
    self.value = value
    super.init(module: module, range: range)
  }

  // Public

  /// The pattern to match.
  public var pattern: Expr
  /// The expression to evaluate if the match is successful.
  public var value: Expr

  /// The scope delimited by the match case.
  ///
  /// Just like the branches of conditional expressions, match cases also push a new scope on the
  /// stack, so that named declarations that may appear in it do not interfere with other cases.
  public var innerScope: Scope?

  override public func copy() -> MatchCase {
    // print("AST: MatchCase", self.module)
    let e = MatchCase(
      pattern: pattern.copy(),
      value: value.copy(),
      module: module,
      range: range.copy()
    )
    e.innerScope = innerScope?.copy()
    // print("AST: MatchCase 2", self.module)
    return e
  }
}

/// A let binding expression.
///
/// Let bindings are typically used in match expressions to express a pattern with an unbound
/// variable in it.
public final class LetBinding: Expr {
  // Lifecycle

  public init(name: String, module: Module, range: SourceRange) {
    self.name = name
    super.init(module: module, range: range)
  }

  // Public

  /// The name of the variable to bind.
  public var name: String

  /// The symbol associated with the type alias.
  public var symbol: Symbol?

  /// The scope in which the alias is defined.
  public var scope: Scope? { symbol?.scope }

  override public func copy() -> LetBinding {
    // print("AST: LetBinding", self.module)
    var e = LetBinding(name: String(name), module: module, range: range.copy())
    // print("AST: LetBinding 2", self.module)
    e.type = type?.copy()
    // print("AST: LetBinding 3", self.module)
    e.symbol = symbol?.copy()
    // print("AST: LetBinding 4", self.module)
    return e
    // print("AST: LetBinding 5", self.module)
  }
}

/// A binary expression.
public final class Binary: Expr {
  // Lifecycle

  public init(
    op: Ident,
    precedence: Int,
    left: Expr,
    right: Expr,
    module: Module,
    range: SourceRange
  ) {
    self.op = op
    self.precedence = precedence
    self.left = left
    self.right = right
    super.init(module: module, range: range)
  }

  // Public

  /// The operator of the expression.
  public var op: Ident
  /// The precedence of the operator.
  public var precedence: Int
  /// The left operand of the expression.
  public var left: Expr
  /// The right operand of the expression.
  public var right: Expr

  override public func copy() -> Binary {
    // print("AST: Binary", self.module)
    var e = Binary(
      op: op.copy(),
      precedence: Int(precedence),
      left: left.copy(),
      right: left.copy(),
      module: module,
      range: range.copy()
    )
    // print("AST: Binary 2", self.module)
    e.type = type?.copy()
    // print("AST: Binary 3", self.module)
    return e
    // print("AST: Binary 4", self.module)
  }
}

/// An unary expression.
public final class Unary: Expr {
  // Lifecycle

  public init(op: Ident, operand: Expr, module: Module, range: SourceRange) {
    self.op = op
    self.operand = operand
    super.init(module: module, range: range)
  }

  // Public

  /// The operator of the expression.
  public var op: Ident
  /// The operand of the expression.
  public var operand: Expr

  override public func copy() -> Unary {
    // print("AST: Unary", self.module)
    var e = Unary(
      op: op.copy(),
      operand: operand.copy(),
      module: module,
      range: range.copy()
    )
    // print("AST: Unary 2", self.module)
    e.type = type?.copy()
    // print("AST: Unary 3", self.module)
    return e
    // print("AST: Unary 4", self.module)
  }
}

/// A function call.
public final class Call: Expr {
  // Lifecycle

  public init(callee: Expr, arguments: [Arg], module: Module, range: SourceRange) {
    self.callee = callee
    self.arguments = arguments
    super.init(module: module, range: range)
  }

  // Public

  /// The callee.
  public var callee: Expr
  /// The arguments of the call.
  public var arguments: [Arg]

  override public func copy() -> Call {
    // print("AST: Call", self.module)
    var e = Call(
      callee: callee.copy(),
      arguments: try arguments.map { $0.copy() },
      module: module,
      range: range.copy()
    )
    // print("AST: Call 2", self.module)
    e.type = type?.copy()
    // print("AST: Call 3", self.module)
    return e
    // print("AST: Call 4", self.module)
  }
}

/// A function argument.
public final class Arg: Expr {
  // Lifecycle

  public init(label: String?, value: Expr, module: Module, range: SourceRange) {
    self.label = label
    self.value = value
    super.init(module: module, range: range)
  }

  // Public

  /// The label of the argument.
  public var label: String?
  /// The value of the argument.
  public var value: Expr

  override public func copy() -> Arg {
    // print("AST: Arg", self.module)
    var e = Arg(
      label: (label != nil) ? String(label!) : nil,
      value: value.copy(),
      module: module,
      range: range.copy()
    )
    // print("AST: Arg 2", self.module)
    e.type = type?.copy()
    // print("AST: Arg 3", self.module)
    return e
    // print("AST: Arg 4", self.module)
  }
}

/// A tuple expression.
public final class Tuple: Expr {
  // Lifecycle

  public init(
    label: String?,
    elements: [TupleElem],
    module: Module,
    range: SourceRange
  ) {
    self.label = label
    self.elements = elements
    super.init(module: module, range: range)
  }

  // Public

  /// The label of the tuple.
  public var label: String?
  /// The elements of the tuple.
  public var elements: [TupleElem]

  override public func copy() -> Tuple {
    let l = (label != nil) ? String(label!) : nil
    var e = Tuple(
      label: l,
      elements: try elements.map { $0.copy() },
      module: module,
      range: range.copy()
    )
    e.type = type?.copy()
    return e
  }
}

/// A tuple element.
public final class TupleElem: Expr {
  // Lifecycle

  public init(label: String?, value: Expr, module: Module, range: SourceRange) {
    self.label = label
    self.value = value
    super.init(module: module, range: range)
  }

  // Public

  /// The label of the tuple element.
  public var label: String?
  /// The value of the tuple element.
  public var value: Expr

  override public func copy() -> TupleElem {
    // print("AST: TupleElem", self.module)
    let l = (label != nil) ? String(label!) : nil
    // print("AST: TupleElem 2", self.module)
    var e = TupleElem(
      label: l,
      value: value.copy(),
      module: module,
      range: range.copy()
    )
    // print("AST: TupleElem 3", self.module)
    e.type = type?.copy()
    // print("AST: TupleElem 4", self.module)
    return e
    // print("AST: TupleElem 5", self.module)
  }
}

/// A select expression.
public final class Select: Expr {
  // Lifecycle

  public init(owner: Expr, ownee: Ownee, module: Module, range: SourceRange) {
    self.owner = owner
    self.ownee = ownee
    super.init(module: module, range: range)
  }

  // Public

  public enum Ownee: CustomStringConvertible {
    case label(String)
    case index(Int)

    // Public

    public var description: String {
      switch self {
      case .label(let label): return label
      case .index(let index): return index.description
      }
    }
  }

  /// The owner.
  public var owner: Expr
  /// The ownee.
  public var ownee: Ownee

  override public func copy() -> Select {
    // print("AST: Select", self.module)
    var e = Select(
      owner: owner.copy(),
      ownee: ownee,
      module: module,
      range: range.copy()
    )
    // print("AST: Select 2", self.module)
    e.type = type?.copy()
    // print("AST: Select 3", self.module)
    return e
    // print("AST: Select 4", self.module)
  }
}

/// An identifier.
public final class Ident: Expr {
  // Lifecycle

  public init(name: String, module: Module, range: SourceRange) {
    self.name = name
    super.init(module: module, range: range)
  }

  // Public

  /// The name of the identifier.
  public var name: String
  /// The scope in which the identifier's defined.
  public var scope: Scope?

  /// The symbol associated with the name of this identifier.
  ///
  /// Identifiers might refer to overloaded names. As such, unlike other named nodes, they have to
  /// annotated with the symbol they actually refer to, which will be defined during the static
  /// dispatching phase.
  public var symbol: Symbol?

  override public func copy() -> Ident {
    // print("AST: Ident", self.module)
    var e = Ident(name: String(name), module: module, range: range.copy())
    // print("AST: Ident 2", self.module)
    e.type = type?.copy()
    // print("AST: Ident 3", self.module)
    e.scope = scope?.copy()
    // print("AST: Ident 4", self.module)
    e.symbol = symbol?.copy(scope: e.scope)
    // print("AST: Ident 5", self.module)
    return e
    // print("AST: Ident 6", self.module)
  }
}

/// A scalar literal.
public final class Scalar<T>: Expr {
  // Lifecycle

  public init(value: T, module: Module, range: SourceRange) {
    self.value = value
    super.init(module: module, range: range)
  }

  // Public

  /// The value of the scalar.
  public var value: T

  override public func copy() -> Scalar<T> {
    // print("AST: Scalar", self.module)
    // print(self.value)
    // print("AST: Scalar 2", self.module)
    // print(module)
    // print("AST: Scalar 3", self.module)
    var e = Scalar<T>(value: value, module: module, range: range.copy())
    // print("AST: Scalar 4", self.module)
    e.type = type?.copy()
    // print("AST: Scalar 5", self.module)
    return e
    // print("AST: Scalar 6", self.module)
  }
}
