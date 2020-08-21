/// Common interface for all AST nodes.
///
/// An Abstract Syntax Tree (AST) is a tree representation of a source code. Each node represents a
/// particular construction (e.g. a variable declaration), with each child representing a sub-
/// construction (e.g. the name of the variable being declared). The term "abstract" denotes the
/// fact that concrete syntactic details such as spaces and line returns are *abstracted* away.
import Foundation

public class Node: Equatable {
  public func copy() -> Node {
    // print("AST: Node", self.module)
    return Node(module: self.module.copy(), range: self.range.copy())
    // print("AST: Node 2", self.module)
  }

  fileprivate init(module: Module?, range: SourceRange) {
    self.module = module
    self.range = range
  }

  /// The module that contains the node.
  public weak var module: Module!
  /// Stores the ranges in the source file of the concrete syntax this node represents.
  public var range: SourceRange

  public static func == (lhs: Node, rhs: Node) -> Bool {
    return lhs === rhs
  }

}

/// An Alpine module.
///
/// This node represents an Alpine module (i.e. the semantics definition of a net).
public final class Module: Node {
  override public func copy() -> Module {
    // print("AST: Module", self.module)
    self.statements.forEach { print($0.module) }
    // print("AST: Module 2", self.module)
    let mod = Module(statements: [], range: self.range.copy())
    // print("AST: Module 3", self.module)
    mod.statements = try self.statements.map { $0.module = mod; return $0.copy() }
    // print("AST: Module 4", self.module)
    try self.statements.forEach { $0.module = self }
    // print("AST: Module 5", self.module)

    /* let mod = Module(statements: try self.statements.map { $0.copy() }, range: self.range.copy()) */
    mod.id = (self.id != nil) ? String(self.id!) : nil
    mod.innerScope = self.innerScope?.copy()
    return mod
  }

  public init(statements: [Node], range: SourceRange) {
    self.statements = statements
    super.init(module: nil, range: range)
    self.module = self
  }

  /// Stores the statements of the module.
  public var statements: [Node]
  /// The identifier of the module.
  public var id: String?
  /// The scope delimited by the module.
  public var innerScope: Scope?

  /// The top-level function declarations.
  public var functions: [Symbol: Func] {
    let symbolsAndNodes = statements
      .compactMap({ node in node as? Func })
      .compactMap({ node in node.symbol.map({ sym in (sym, node) }) })
    return Dictionary(uniqueKeysWithValues: symbolsAndNodes)
  }

}

/// A function declaration.
public final class Func: Expr {
  override public func copy() -> Func {
    // print("AST: Func 1", self.module)
    let n = (self.name != nil) ? String(self.name!) : nil
    // print("AST: Func 2", self.module)
    var f = Func(name: n, signature: self.signature.copy(), body: self.body.copy(), module: self.module, range: self.range.copy())
    // print("AST: Func 3", self.module)
    f.type = self.type?.copy()
    // print("AST: Func 4", self.module)
    f.symbol = self.symbol?.copy(scope: self.symbol?.scope.copy())
    // print("AST: Func 5", self.module)
    print(self.symbol?.scope, self.symbol?.name, self.symbol?.type)
    print(f.symbol)
    print(f.symbol?.name)
    print(f.symbol?.type)
    print(f.symbol?.scope)
    f.innerScope = self.innerScope?.copy()
    // print("AST: Func 6", self.module)
    return f
  }

  public init(
    name: String?,
    signature: FuncSign,
    body: Expr,
    module: Module,
    range: SourceRange)
  {
    self.name = name
    self.signature = signature
    self.body = body
    super.init(module: module, range: range)
  }

  /// The (optional) name of the function.
  public var name: String?
  /// The signature of the function.
  public var signature: FuncSign
  /// The body of the function.
  public var body: Expr

  /// The symbol associated with the function.
  public var symbol: Symbol? {
    didSet {
      type = symbol?.type
    }
  }

  /// The scope in which the function is defined.
  public var scope: Scope? { return symbol?.scope }
  /// The scope delimited by the function.
  public var innerScope: Scope?

}

/// A type alias declaration.
public final class TypeAlias: Node {
  override public func copy() -> TypeAlias {
    // print("AST: TypeAlias", self.module)
    var e = TypeAlias(name: String(self.name), signature: self.signature.copy(), module: self.module, range: self.range.copy())
    // print("AST: TypeAlias 2", self.module)
    let fff = self.symbol?.scope.copy()
    // print("AST: TypeAlias 3", self.module)
    e.symbol = self.symbol?.copy(scope: fff)
    // print("AST: TypeAlias 4", self.module)
    print("hahahahaha")
    // print("AST: TypeAlias 5", self.module)
    e.scope?.symbols.forEach { print("Symbol:", $0.key, $0.value); $0.value.forEach { print("  val:", $0.scope, $0.scope.id, $0.type)} }
    // print("AST: TypeAlias 6", self.module)
    print("hrlooo")
    // print("AST: TypeAlias 7", self.module)
    print(self.symbol?.scope)
    print(e.symbol?.scope)
    return e
  }

  public init(name: String, signature: TypeSign, module: Module, range: SourceRange) {
    self.name = name
    self.signature = signature
    super.init(module: module, range: range)
  }

  /// The name of the alias.
  public var name: String
  /// The signature of the alias.
  public var signature: TypeSign
  /// The symbol associated with the type alias.
  public var symbol: Symbol?
  /// The scope in which the alias is defined.
  public var scope: Scope? { return symbol?.scope }

}

/// Base class for nodes representing a type signature.
public class TypeSign: Node {
  override public func copy() -> TypeSign {
    // print("AST: TypeSign", self.module)
    var e = TypeSign(module: self.module, range: self.range.copy())
    // print("AST: TypeSign 2", self.module)
    e.type = self.type?.copy()
    // print("AST: TypeSign 3", self.module)
    return e
    // print("AST: TypeSign 4", self.module)
  }

  /// The type of the signature.
  public var type: Metatype?

}

/// A type identifier.
public final class TypeIdent: TypeSign {
  override public func copy() -> TypeIdent {
    // print("AST: TypeIdent", self.module)
    var e = TypeIdent(name: String(self.name), module: self.module, range: self.range.copy())
    // print("AST: TypeIdent 2", self.module)
    e.scope = self.scope?.copy()
    // print("AST: TypeIdent 3", self.module)
    e.symbol = self.symbol?.copy(scope: e.scope)
    // print("AST: TypeIdent 4", self.module)
    e.type = self.type?.copy()
    // print("AST: TypeIdent 5", self.module)
    return e
    // print("AST: TypeIdent 6", self.module)
  }

  public init(name: String, module: Module, range: SourceRange) {
    self.name = name
    super.init(module: module, range: range)
  }

  /// The name of the type.
  public var name: String
  /// The scope in which the type identifier's defined.
  public var scope: Scope?
  /// The symbol associated with the name of this type identifier.
  public var symbol: Symbol?

}


/// A function type signature.
public final class FuncSign: TypeSign {
  override public func copy() -> FuncSign {
    // print("AST: FuncSign", self.module)
    var e = FuncSign(domain: self.domain.copy(), codomain: self.codomain.copy(), module: self.module, range: self.range.copy())
    // print("AST: FuncSign 2", self.module)
    e.type = self.type?.copy()
    // print("AST: FuncSign 3", self.module)
    return e
    // print("AST: FuncSign 4", self.module)
  }

  public init(domain: TupleSign, codomain: TypeSign, module: Module, range: SourceRange) {
    self.domain = domain
    self.codomain = codomain
    super.init(module: module, range: range)
  }

  /// The domain of the function.
  public var domain: TupleSign
  /// The codomain of the function.
  public var codomain: TypeSign

}

/// A tuple type signature.
public final class TupleSign: TypeSign {
  override public func copy() -> TupleSign {
    // print("AST: TupleSign", self.module)
    let l = (self.label != nil) ? String(self.label!) : nil
    // print("AST: TupleSign 2", self.module)
    var e = TupleSign(label: l, elements: try self.elements.map { $0.copy() }, module: self.module, range: self.range.copy())
    // print("AST: TupleSign 3", self.module)
    print("hhh2", self.type, self.type?.type)
    // print("AST: TupleSign 4", self.module)
    e.type = self.type?.copy()
    // print("AST: TupleSign 5", self.module)
    return e
    // print("AST: TupleSign 6", self.module)
  }

  public init(label: String?, elements: [TupleSignElem], module: Module, range: SourceRange) {
    self.label = label
    self.elements = elements
    super.init(module: module, range: range)
  }

  /// The label of the tuple signature.
  public var label: String?
  /// The elements of the tuple signature.
  public var elements: [TupleSignElem]

}

/// A tuple element signature.
public final class TupleSignElem: Node {
  override public func copy() -> TupleSignElem {
    // print("AST: TupleSignElem", self.module)
    let l = (self.label != nil) ? String(self.label!) : nil
    // print("AST: TupleSignElem 2", self.module)
    let n = (self.name != nil) ? String(self.name!) : nil
    // print("AST: TupleSignElem 3", self.module)

    return TupleSignElem(label: l, name: n, signature: self.signature.copy(), module: self.module, range: self.range.copy())
  }

  public init(
    label: String?,
    name: String?,
    signature: TypeSign,
    module: Module,
    range: SourceRange)
  {
    self.label = label
    self.name = name
    self.signature = signature
    super.init(module: module, range: range)
  }

  /// The label of the tuple element.
  public var label: String?
  /// The name of the tuple element (for function domains only).
  public var name: String?
  /// The signature of the tuple element.
  public var signature: TypeSign

}

/// A union signature.
public final class UnionSign: TypeSign {
  override public func copy() -> UnionSign {
    // print("AST: UnionSign", self.module)
    var e = UnionSign(cases: try self.cases.map { $0.copy() }, module: self.module, range: self.range.copy())
    // print("AST: UnionSign 2", self.module)
    e.type = self.type?.copy()
    // print("AST: UnionSign 3", self.module)
    return e
    // print("AST: UnionSign 4", self.module)
  }

  public init(cases: [TypeSign], module: Module, range: SourceRange) {
    self.cases = cases
    super.init(module: module, range: range)
  }

  /// The cases of the union.
  public var cases: [TypeSign]

}

/// Base class for node representing an expression.
public class Expr: Node {

  override public func copy() -> Expr {
    // print("AST: Expr", self.module)
    var e = Expr(module: self.module, range: self.range.copy())
    // print("AST: Expr 2", self.module)
    e.type = (self.type != nil) ? self.type?.copy() : nil
    // print("AST: Expr 3", self.module)
    return e
    // print("AST: Expr 4", self.module)
  }

  /// The type of the expression.
  public var type: TypeBase?

}

/// A conditional expression.
public final class If: Expr {
  override public func copy() -> If {
    // print("AST: If", self.module)
    var e = If(condition: self.condition.copy(), thenExpr: self.thenExpr.copy(), elseExpr: self.elseExpr.copy(), module: self.module, range: self.range.copy())
    // print("AST: If 2", self.module)
    e.type = self.type?.copy()
    // print("AST: If 3", self.module)
    return e
    // print("AST: If 4", self.module)
  }

  public init(
    condition: Expr,
    thenExpr: Expr,
    elseExpr: Expr,
    module: Module,
    range: SourceRange)
  {
    self.condition = condition
    self.thenExpr = thenExpr
    self.elseExpr = elseExpr
    super.init(module: module, range: range)
  }

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

}

/// A match expression.
public final class Match: Expr {
  override public func copy() -> Match {
    // print("AST: Match", self.module)
    var e = Match(subject: self.subject.copy(), cases: self.cases.map { $0.copy() }, module: self.module, range: self.range.copy())
    // print("AST: Match 2", self.module)
    e.type = self.type?.copy()
    // print("AST: Match 3", self.module)
    return e
  }

  public init(subject: Expr, cases: [MatchCase], module: Module, range: SourceRange) {
    self.subject = subject
    self.cases = cases
    super.init(module: module, range: range)
  }

  /// The subject of the match.
  public var subject: Expr
  /// The case of the match.
  public var cases: [MatchCase]

}

/// A match case.
public final class MatchCase: Node {
  override public func copy() -> MatchCase {
    // print("AST: MatchCase", self.module)
    let e = MatchCase(pattern: self.pattern.copy(), value: self.value.copy(), module: self.module, range: self.range.copy())
    e.innerScope = self.innerScope?.copy()
    // print("AST: MatchCase 2", self.module)
    return e
  }

  public init(pattern: Expr, value: Expr, module: Module, range: SourceRange) {
    self.pattern = pattern
    self.value = value
    super.init(module: module, range: range)
  }

  /// The pattern to match.
  public var pattern: Expr
  /// The expression to evaluate if the match is successful.
  public var value: Expr

  /// The scope delimited by the match case.
  ///
  /// Just like the branches of conditional expressions, match cases also push a new scope on the
  /// stack, so that named declarations that may appear in it do not interfere with other cases.
  public var innerScope: Scope?

}

/// A let binding expression.
///
/// Let bindings are typically used in match expressions to express a pattern with an unbound
/// variable in it.
public final class LetBinding: Expr {
  override public func copy() -> LetBinding {
    // print("AST: LetBinding", self.module)
    var e = LetBinding(name: String(self.name), module: self.module, range: self.range.copy())
    // print("AST: LetBinding 2", self.module)
    e.type = self.type?.copy()
    // print("AST: LetBinding 3", self.module)
    e.symbol = self.symbol?.copy()
    // print("AST: LetBinding 4", self.module)
    return e
    // print("AST: LetBinding 5", self.module)
  }

  public init(name: String, module: Module, range: SourceRange) {
    self.name = name
    super.init(module: module, range: range)
  }

  /// The name of the variable to bind.
  public var name: String

  /// The symbol associated with the type alias.
  public var symbol: Symbol?
  /// The scope in which the alias is defined.
  public var scope: Scope? { return symbol?.scope }

}

/// A binary expression.
public final class Binary: Expr {
  override public func copy() -> Binary {
    // print("AST: Binary", self.module)
    var e = Binary(op: self.op.copy(), precedence: Int(self.precedence), left: self.left.copy(), right: self.left.copy(), module: self.module, range: self.range.copy())
    // print("AST: Binary 2", self.module)
    e.type = self.type?.copy()
    // print("AST: Binary 3", self.module)
    return e
    // print("AST: Binary 4", self.module)
  }

  public init(
    op: Ident,
    precedence: Int,
    left: Expr,
    right: Expr,
    module: Module,
    range: SourceRange)
  {
    self.op = op
    self.precedence = precedence
    self.left = left
    self.right = right
    super.init(module: module, range: range)
  }

  /// The operator of the expression.
  public var op: Ident
  /// The precedence of the operator.
  public var precedence: Int
  /// The left operand of the expression.
  public var left: Expr
  /// The right operand of the expression.
  public var right: Expr

}

/// An unary expression.
public final class Unary: Expr {
  override public func copy() -> Unary {
    // print("AST: Unary", self.module)
    var e = Unary(op: self.op.copy(), operand: self.operand.copy(), module: self.module, range: self.range.copy())
    // print("AST: Unary 2", self.module)
    e.type = self.type?.copy()
    // print("AST: Unary 3", self.module)
    return e
    // print("AST: Unary 4", self.module)
  }

  public init(op: Ident, operand: Expr, module: Module, range: SourceRange) {
    self.op = op
    self.operand = operand
    super.init(module: module, range: range)
  }

  /// The operator of the expression.
  public var op: Ident
  /// The operand of the expression.
  public var operand: Expr

}

/// A function call.
public final class Call: Expr {
  override public func copy() -> Call {
    // print("AST: Call", self.module)
    var e = Call(callee: self.callee.copy(), arguments: try self.arguments.map { $0.copy() }, module: self.module, range: self.range.copy())
    // print("AST: Call 2", self.module)
    e.type = self.type?.copy()
    // print("AST: Call 3", self.module)
    return e
    // print("AST: Call 4", self.module)
  }

  public init(callee: Expr, arguments: [Arg], module: Module, range: SourceRange) {
    self.callee = callee
    self.arguments = arguments
    super.init(module: module, range: range)
  }

  /// The callee.
  public var callee: Expr
  /// The arguments of the call.
  public var arguments: [Arg]

}

/// A function argument.
public final class Arg: Expr {
  override public func copy() -> Arg {
    // print("AST: Arg", self.module)
    var e = Arg(label: (self.label != nil) ? String(label!) : nil, value: self.value.copy(), module: self.module, range: self.range.copy())
    // print("AST: Arg 2", self.module)
    e.type = self.type?.copy()
    // print("AST: Arg 3", self.module)
    return e
    // print("AST: Arg 4", self.module)
  }

  public init(label: String?, value: Expr, module: Module, range: SourceRange) {
    self.label = label
    self.value = value
    super.init(module: module, range: range)
  }

  /// The label of the argument.
  public var label: String?
  /// The value of the argument.
  public var value: Expr

}

/// A tuple expression.
public final class Tuple: Expr {
  override public func copy() -> Tuple {
    // print("AST: Tuple", self.module)
    print("1111111111111111111111111111111111111111111111")
    // print("AST: Tuple 2", self.module)
    let l = (self.label != nil) ? String(self.label!) : nil
    // print("AST: Tuple 3", self.module)
    print("22222222222222222222222222222222222222222222222:", self.elements)
    // print("AST: Tuple 4", self.module)
    var e = Tuple(label: l, elements: try self.elements.map { $0.copy() }, module: self.module, range: self.range.copy())
    // print("AST: Tuple 5", self.module)
    print("3333333333333333333333333333333333333333333333333333")
    // print("AST: Tuple 6", self.module)
    e.type = self.type?.copy()
    // print("AST: Tuple 7", self.module)
    print("444444444444444444444444444444444444444444")
    return e
  }

  public init(label: String?, elements: [TupleElem], module: Module, range: SourceRange) {
    self.label = label
    self.elements = elements
    super.init(module: module, range: range)
  }

  /// The label of the tuple.
  public var label: String?
  /// The elements of the tuple.
  public var elements: [TupleElem]

}

/// A tuple element.
public final class TupleElem: Expr {
  override public func copy() -> TupleElem{
    // print("AST: TupleElem", self.module)
    let l = (self.label != nil) ? String(self.label!) : nil
    // print("AST: TupleElem 2", self.module)
    var e = TupleElem(label: l, value: self.value.copy(), module: self.module, range: self.range.copy())
    // print("AST: TupleElem 3", self.module)
    e.type = self.type?.copy()
    // print("AST: TupleElem 4", self.module)
    return e
    // print("AST: TupleElem 5", self.module)
  }

  public init(label: String?, value: Expr, module: Module, range: SourceRange) {
    self.label = label
    self.value = value
    super.init(module: module, range: range)
  }

  /// The label of the tuple element.
  public var label: String?
  /// The value of the tuple element.
  public var value: Expr

}

/// A select expression.
public final class Select: Expr {
  override public func copy() -> Select {
    // print("AST: Select", self.module)
    var e = Select(owner: self.owner.copy(), ownee: self.ownee, module: self.module, range: self.range.copy())
    // print("AST: Select 2", self.module)
    e.type = self.type?.copy()
    // print("AST: Select 3", self.module)
    return e
    // print("AST: Select 4", self.module)
  }

  public enum Ownee: CustomStringConvertible {

    case label(String)
    case index(Int)

    public var description: String {
      switch self {
      case .label(let label): return label
      case .index(let index): return index.description
      }
    }

  }

  public init(owner: Expr, ownee: Ownee, module: Module, range: SourceRange) {
    self.owner = owner
    self.ownee = ownee
    super.init(module: module, range: range)
  }

  /// The owner.
  public var owner: Expr
  /// The ownee.
  public var ownee: Ownee

}

/// An identifier.
public final class Ident: Expr {
  override public func copy() -> Ident {
    // print("AST: Ident", self.module)
    var e = Ident(name: String(self.name), module: self.module, range: self.range.copy())
    // print("AST: Ident 2", self.module)
    e.type = self.type?.copy()
    // print("AST: Ident 3", self.module)
    e.scope = self.scope?.copy()
    // print("AST: Ident 4", self.module)
    e.symbol = self.symbol?.copy(scope: e.scope)
    // print("AST: Ident 5", self.module)
    return e
    // print("AST: Ident 6", self.module)
  }

  public init(name: String, module: Module, range: SourceRange) {
    self.name = name
    super.init(module: module, range: range)
  }

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

}

/// A scalar literal.
public final class Scalar<T>: Expr {
  override public func copy() -> Scalar<T> {
    // print("AST: Scalar", self.module)
    print(self.value)
    // print("AST: Scalar 2", self.module)
    print(module)
    // print("AST: Scalar 3", self.module)
    var e = Scalar<T>(value: self.value, module: module, range: self.range.copy()) 
    // print("AST: Scalar 4", self.module)
    e.type = self.type?.copy()
    // print("AST: Scalar 5", self.module)
    return e
    // print("AST: Scalar 6", self.module)
  }

  public init(value: T, module: Module, range: SourceRange) {
    self.value = value
    super.init(module: module, range: range)
  }

  /// The value of the scalar.
  public var value: T

}
