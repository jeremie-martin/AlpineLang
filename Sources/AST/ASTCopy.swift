public protocol ASTCopy {
  /* var replace: [String: Expr] { get set } */

  func copy(_ node: Module)          throws -> Node

  // MARK: Declarations

  func copy(_ node: Func)            throws -> Node
  func copy(_ node: TypeAlias)       throws -> Node

  // MARK: Type signatures

  func copy(_ node: FuncSign)        throws -> Node
  func copy(_ node: TupleSign)       throws -> Node
  func copy(_ node: TupleSignElem)   throws -> Node
  func copy(_ node: UnionSign)       throws -> Node
  func copy(_ node: TypeIdent)       throws -> Node

  // MARK: Expressions

  func copy(_ node: If)              throws -> Node
  func copy(_ node: Match)           throws -> Node
  func copy(_ node: MatchCase)       throws -> Node
  func copy(_ node: LetBinding)      throws -> Node
  func copy(_ node: Binary)          throws -> Node
  func copy(_ node: Unary)           throws -> Node
  func copy(_ node: Call)            throws -> Node
  func copy(_ node: Arg)             throws -> Node
  func copy(_ node: Tuple)           throws -> Node
  func copy(_ node: TupleElem)       throws -> Node
  func copy(_ node: Select)          throws -> Node
  func copy(_ node: Ident)           throws -> Node
  func copy(_ node: Scalar<Bool>)    throws -> Node
  func copy(_ node: Scalar<Int>)     throws -> Node
  func copy(_ node: Scalar<Double>)  throws -> Node
  func copy(_ node: Scalar<String>)  throws -> Node

}
