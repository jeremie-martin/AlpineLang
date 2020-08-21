import AST
import Foundation

public struct Console: TextOutputStream {

  public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    let string = items.map({ String(describing: $0) }).joined(separator: separator) + terminator
    write(string)
  }

  public func write(_ string: String) {
    fputs(string, file)
  }

  public static var out = Console(file: stdout)
  public static var err = Console(file: stderr)

  private init(file: UnsafeMutablePointer<FILE>) {
    self.file = file
  }

  private var file: UnsafeMutablePointer<FILE>

}

public final class ConstraintCreator: ASTVisitor, SAPass {

  public init(context: ASTContext) {
    self.context = context
  }

  public func visit(_ node: Func) throws {
    let funcType = node.type as! FunctionType
    let signType = read(signature: node.signature)
    context.add(
      constraint: .equality(t: funcType, u: signType, at: .location(node, .signature)))

    try visit(node.body)
    context.add(
      constraint: .conformance(
        t: node.body.type!, u: funcType.codomain, at: .location(node, .body)))
  }

  /// The AST context.
  public let context: ASTContext

  private func read(signature: TypeSign) -> TypeBase {
    switch signature {
    case let s as FuncSign : return read(signature: s)
    case let s as TupleSign: return read(signature: s)
    case let s as TypeIdent: return read(signature: s)
    case let s as UnionSign: return read(signature: s)
    default:
      fatalError("unreachable")
    }
  }

  public func visit(_ node: TypeAlias) throws {
    guard let t = node.symbol?.type
      else { return }
    assert(t is Metatype)

    let u = read(signature: node.signature).metatype
    context.add(constraint: .equality(t: t, u: u, at: .location(node, .signature)))
  }

  public func visit(_ node: If) throws {
    // The condition of a conditional expression is always boolean.
    try visit(node.condition)
    context.add(constraint:
      .equality(t: node.condition.type!, u: BuiltinType.bool, at: .location(node, .condition)))

    // Infer the type constraints of both branches.
    try visit(node.thenExpr)
    try visit(node.elseExpr)

    // Both branches may return different construtors, and therfore have different types. To cater
    // for that, we type the node itself with a union of the two.
    node.type = context.getUnionType(cases: [node.thenExpr.type!, node.elseExpr.type!])
  }

  public func visit(_ node: Match) throws {
    // First, we need to create the type constraints for the match subject.
    try visit(node.subject)

    // Second, visit all cases to infer the respective type constraints.
    try visit(node.cases)

    // Just as for conditional expressions, create the type of the match as the union of all
    // branches, as each might be returning a different constructor, and would hence have a
    // different type.
    node.type = context.getUnionType(cases: Set(node.cases.map({ $0.value.type! })))

    // Each case pattern should conform to the type of the subject.
    for (i, matchCase) in node.cases.enumerated() {
      context.add(constraint: .conformance(
        t: matchCase.pattern.type!,
        u: node.subject.type!,
        at: .location(node, .matchPattern(i))))
    }
  }

  public func visit(_ node: MatchCase) throws {
    try visit(node.pattern)
    try visit(node.value)
    // node.type = node.value.type
  }

  public func visit(_ node: Binary) {
    fatalError("AST not normalized, did you forget to apply the normalizer?")
  }

  public func visit(_ node: Unary) {
    fatalError("AST not normalized, did you forget to apply the normalizer?")
  }

  public func visit(_ node: Call) throws {
    // Build the supposed type of the callee's parameters.
    let elements = node.arguments.map { TupleTypeElem(label: $0.label, type: TypeVariable()) }
    for (i, (arg, elem)) in zip(node.arguments, elements).enumerated() {
      try visit(arg)
      context.add(constraint:
        .conformance(t: arg.type!, u: elem.type, at: .location(node, .tuple) + .elementIndex(i)))
    }

    // Build the supposed type of the callee.
    node.type = TypeVariable()
    try visit(node.callee)
    let domain = context.getTupleType(label: nil, elements: elements)
    let funcType = context.getFunctionType(from: domain, to: node.type!)

    context.add(constraint:
      .equality(t: node.callee.type!, u: funcType, at: .location(node, .callee)))
  }

  public func visit(_ node: Arg) throws {
    try visit(node.value)
    node.type = node.value.type
  }

  public func visit(_ node: Tuple) throws {
    for elem in node.elements {
      try visit(elem)
    }
    node.type = context.getTupleType(
      label: node.label,
      elements: node.elements.map { TupleTypeElem(label: $0.label, type: $0.type!) })
  }

  public func visit(_ node: TupleElem) throws {
    try visit(node.value)
    node.type = node.value.type
  }

  public func visit(_ node: Select) throws {
    try visit(node.owner)

    // The type of the node itself has to be inferred from the context.
    node.type = TypeVariable()

    let path: ConstraintPath
    switch node.ownee {
    case .label(let label):
      path = .elementLabel(label)
    case .index(let index):
      path = .elementIndex(index)
    }
    context.add(constraint:
      .member(t: node.owner.type!, member: node.ownee, u: node.type!, at: .location(node, path)))
  }

  public func visit(_ node: Ident) throws {
    // Retrieve the symbol(s) associated with the identifier.
    guard let symbols = node.scope?.symbols[node.name] else {
      node.type = ErrorType.get
      return
    }

    // FIXME: Load overloads from parent scopes. To make sure we respect shadowing, we could stop
    // looking further down the stack as soon as we encounter a non-overloadable symbol, as this
    // property should have been properly set during the name binding pass.

    // Create a disjunction of constraint for each symbol, so as to let the solver explore the
    // different possible choices.
    node.type = TypeVariable()
    let choices: [Constraint] = symbols.map {
      .equality(t: node.type!, u: $0.type!, at: .location(node, .identifier))
    }
    if choices.count == 1 {
      context.add(constraint: choices[0])
    } else {
      context.add(constraint: .disjunction(choices, at: .location(node, .identifier)))
    }
  }

  public func visit(_ node: Scalar<Bool>) throws {
    node.type = BuiltinType.bool
  }

  public func visit(_ node: Scalar<Int>) throws {
    node.type = BuiltinType.int
  }

  public func visit(_ node: Scalar<Double>) throws {
    node.type = BuiltinType.float
  }

  public func visit(_ node: Scalar<String>) throws {
    node.type = BuiltinType.string
  }

  // MARK: Type signature handling

  private func read(signature: FuncSign) -> TypeBase {
    return context.getFunctionType(
      from: read(signature: signature.domain),
      to  : read(signature: signature.codomain))
  }

  private func read(signature: TupleSign) -> TupleType {
    return context.getTupleType(
      label: signature.label,
      elements: signature.elements.map({
        TupleTypeElem(label: $0.label, type: read(signature: $0.signature))
      }))
  }

  private func read(signature: UnionSign) -> TypeBase {
    return context.getUnionType(cases: Set(signature.cases.map({ read(signature: $0) })))
  }

  private func read(signature: TypeIdent) -> TypeBase {
    guard let symbols = signature.scope?.symbols[signature.name] else {
      // The symbols of an identifier couldn't be linked; we use an error type.
      context.add(error: SAError.undefinedSymbol(name: signature.name), on: signature)
      return ErrorType.get
    }

    // Type identifiers should be associated with a unique metatype.
    guard symbols.count == 1, let meta = symbols[0].type as? Metatype else {
      context.add(error: SAError.invalidTypeIdentifier(name: signature.name), on: signature)
      return ErrorType.get
    }

    signature.type = meta
    return meta.type
  }

}
