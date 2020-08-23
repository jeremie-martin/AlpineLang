public extension ASTCopy {

  // swiftlint:disable cyclomatic_complexity
  func copy(_ node: Node) throws -> Node {
    switch node {
    case let n as Module:          return try copy(n)
    case let n as Func:            return try copy(n)
    case let n as TypeAlias:       return try copy(n)
    case let n as FuncSign:        return try copy(n)
    case let n as TupleSign:       return try copy(n)
    case let n as TupleSignElem:   return try copy(n)
    case let n as UnionSign:       return try copy(n)
    case let n as TypeIdent:       return try copy(n)
    case let n as If:              return try copy(n)
    case let n as Match:           return try copy(n)
    case let n as MatchCase:       return try copy(n)
    case let n as LetBinding:      return try copy(n)
    case let n as Binary:          return try copy(n)
    case let n as Unary:           return try copy(n)
    case let n as Call:            return try copy(n)
    case let n as Arg:             return try copy(n)
    case let n as Tuple:           return try copy(n)
    case let n as TupleElem:       return try copy(n)
    case let n as Select:          return try copy(n)
    case let n as Ident:           return try copy(n)
    case let n as Scalar<Bool>:    return try copy(n)
    case let n as Scalar<Int>:     return try copy(n)
    case let n as Scalar<Double>:  return try copy(n)
    case let n as Scalar<String>:  return try copy(n)
    default:
      fatalError("unexpected node during generic copy")
    }
  }
  // swiftlint:enable cyclomatic_complexity

  func copy(_ node: Module) throws -> Node {
    node.statements = try node.statements.map(copy)
    return node
  }

  // MARK: Declarations

  func copy(_ node: Func) throws -> Node {
    node.signature = try copy(node.signature) as! FuncSign
    node.body = try copy(node.body) as! Expr
    return node
  }

  func copy(_ node: TypeAlias) throws -> Node {
    node.signature = try copy(node.signature) as! TypeSign
    return node
  }

  // MARK: Type signatures

  func copy(_ node: FuncSign) throws -> Node {
    node.domain = try copy(node.domain) as! TupleSign
    node.codomain = try copy(node.codomain) as! TypeSign
    return node
  }

  func copy(_ node: TupleSign) throws -> Node {
    node.elements = try node.elements.map(copy) as! [TupleSignElem]
    return node
  }

  func copy(_ node: TupleSignElem) throws -> Node {
    node.signature = try copy(node.signature) as! TypeSign
    return node
  }

  func copy(_ node: UnionSign) throws -> Node {
    node.cases = try node.cases.map(copy) as! [TypeSign]
    return node
  }

  func copy(_ node: TypeIdent) throws -> Node {
    return node
  }

  // MARK: Expressions

  func copy(_ node: If) throws -> Node {
    node.condition = try copy(node.condition) as! Expr
    node.thenExpr = try copy(node.thenExpr) as! Expr
    node.elseExpr = try copy(node.elseExpr) as! Expr
    return node
  }

  func copy(_ node: Match) throws -> Node {
    node.subject = try copy(node.subject) as! Expr
    node.cases = try node.cases.map(copy) as! [MatchCase]
    return node
  }

  func copy(_ node: MatchCase) throws -> Node {
    node.pattern = try copy(node.pattern) as! Expr
    node.value = try copy(node.value) as! Expr
    return node
  }

  func copy(_ node: LetBinding) throws -> Node {
    return node
  }

  func copy(_ node: Binary) throws -> Node {
    node.op = try copy(node.op) as! Ident
    node.left = try copy(node.left) as! Expr
    node.right = try copy(node.right) as! Expr
    return node
  }

  func copy(_ node: Unary) throws -> Node {
    node.op = try copy(node.op) as! Ident
    node.operand = try copy(node.operand) as! Expr
    return node
  }

  func copy(_ node: Call) throws -> Node {
    node.callee = try copy(node.callee) as! Expr
    node.arguments = try node.arguments.map(copy) as! [Arg]
    return node
  }

  func copy(_ node: Arg) throws -> Node {
    node.value = try copy(node.value) as! Expr
    return node
  }

  func copy(_ node: Tuple) throws -> Node {
    node.elements = try node.elements.map(copy) as! [TupleElem]
    return node
  }

  func copy(_ node: TupleElem) throws -> Node {
    node.value = try copy(node.value) as! Expr
    return node
  }

  func copy(_ node: Select) throws -> Node {
    node.owner = try copy(node.owner) as! Expr
    return node
  }

  func copy(_ node: Ident) -> Node {
    /* if let new = replace[node.name] { */
    /*   return new */
    /* } */
    return node
  }

  func copy(_ node: Scalar<Bool>) -> Node {
    return node
  }

  func copy(_ node: Scalar<Int>) -> Node {
    return node
  }

  func copy(_ node: Scalar<Double>) -> Node {
    return node
  }

  func copy(_ node: Scalar<String>) -> Node {
    return node
  }

}
