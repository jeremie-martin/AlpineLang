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
}

/// Base class for nodes representing a type signature.
public class TypeSign: Node {
  /// The type of the signature.
  public var type: Metatype?
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
}

/// Base class for node representing an expression.
public class Expr: Node {
  /// The type of the expression.
  public var type: TypeBase?
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
}
