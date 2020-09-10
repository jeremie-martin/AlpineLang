import Utils

precedencegroup StreamPrecedence {
  associativity: left
  lowerThan: TernaryPrecedence
}

infix operator <<<: StreamPrecedence

public final class ASTDumper<OutputStream>: ASTVisitor
  where OutputStream: TextOutputStream {
  // Lifecycle

  public init(outputTo outputStream: OutputStream) {
    self.outputStream = outputStream
  }

  // Public

  public var outputStream: OutputStream

  public func dump(ast: Node) {
    try! visit(ast)
    print()
  }

  public func visit(_ node: Module) throws {
    // print("DUMPER: Module", node.module)
    self <<< indent <<< "(module" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " inner_scope='" <<< node.innerScope <<< "'"
    self <<< " inner_scopeid='" <<< node.innerScope?.id <<< "'"

    if !node.statements.isEmpty {
      self <<< "\n"
      withIndentation { try visit(node.statements) }
    }
    self <<< ")"
  }

  public func visit(_ node: Func) throws {
    // print("DUMPER: Func", node.module)
    self <<< indent <<< "(func" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    if let name = node.name {
      self <<< " '\(name)'"
    }
    self <<< " type='" <<< node.type <<< "'"
    self <<< " symbol='" <<< node.symbol?.name <<< "'"
    self <<< " scope='" <<< node.scope <<< "'"
    self <<< " scopeid='" <<< node.scope?.id <<< "'"
    self <<< " inner_scope='" <<< node.innerScope <<< "'"
    self <<< " inner_scopeid='" <<< node.innerScope?.id <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(signature\n"
      withIndentation { try visit(node.signature) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(body\n"
      withIndentation { try visit(node.body) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: TypeAlias) throws {
    // print("DUMPER: TypeAlias", node.module)
    self <<< indent <<< "(type_alias '\(node.name)'" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " symbol='" <<< node.symbol?.name <<< "'"
    self <<< " scope='" <<< node.scope <<< "'"
    self <<< " scopeid='" <<< node.scope?.id <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(signature\n"
      withIndentation { try visit(node.signature) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: FuncSign) throws {
    // print("DUMPER: FuncSign", node.module)
    self <<< indent <<< "(func_sign" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    withIndentation {
      self <<< "\n" <<< indent <<< "(domain\n"
      withIndentation { try visit(node.domain) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(codomain\n"
      withIndentation { try visit(node.codomain) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: TupleSign) throws {
    // print("DUMPER: TupleSign", node.module)
    self <<< indent <<< "(tuple_sign" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    if let label = node.label {
      self <<< " '\(label)'"
    }
    if !node.elements.isEmpty {
      self <<< "\n"
      withIndentation { try visit(node.elements) }
    }
    self <<< ")"
  }

  public func visit(_ node: TupleSignElem) throws {
    // print("DUMPER: TupleSignElem", node.module)
    self <<< indent <<< "(tuple_sign_elem" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " '" <<< node.label <<< "'"
    self <<< " '" <<< node.name <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(signature\n"
      withIndentation { try visit(node.signature) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: UnionSign) throws {
    // print("DUMPER: UnionSign", node.module)
    self <<< indent <<< "(union_sign" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    if !node.cases.isEmpty {
      self <<< "\n"
      withIndentation { try visit(node.cases) }
    }
    self <<< ")"
  }

  public func visit(_ node: TypeIdent) throws {
    // print("DUMPER: TypeIdent", node.module)
    self <<< indent <<< "(type_ident '\(node.name)'" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    self <<< " scope='" <<< node.scope <<< "'"
    self <<< " scopeid='" <<< node.scope?.id <<< "'"
    self <<< ")"
  }

  public func visit(_ node: If) throws {
    // print("DUMPER: If", node.module)
    self <<< indent <<< "(if" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(condition\n"
      withIndentation { try visit(node.condition) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(then"
      self <<< " inner_scope='" <<< node.thenScope <<< "'\n"
      withIndentation { try visit(node.thenExpr) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(else"
      self <<< " inner_scope='" <<< node.elseScope <<< "'\n"
      withIndentation { try visit(node.elseExpr) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: Match) throws {
    // print("DUMPER: Match", node.module)
    self <<< indent <<< "(match" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(subject\n"
      withIndentation { try visit(node.subject) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(cases\n"
      withIndentation { try visit(node.cases) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: MatchCase) throws {
    // print("DUMPER: MatchCase", node.module)
    self <<< indent <<< "(match_case" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " inner_scope='" <<< node.innerScope <<< "'"
    self <<< " inner_scopeid='" <<< node.innerScope?.id <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(pattern\n"
      withIndentation { try visit(node.pattern) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(value\n"
      withIndentation { try visit(node.value) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: LetBinding) throws {
    // print("DUMPER: LetBinding", node.module)
    self <<< indent <<< "(let_binding '\(node.name)'" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    self <<< " scope='" <<< node.scope <<< "'"
    self <<< " scopeid='" <<< node.scope?.id <<< "'"
    self <<< ")"
  }

  public func visit(_ node: Binary) throws {
    // print("DUMPER: Binary", node.module)
    self <<< indent <<< "(binary" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(left\n"
      withIndentation { try visit(node.left) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(infix_operator\n"
      withIndentation { visit(node.op) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(right\n"
      withIndentation { try visit(node.right) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: Unary) throws {
    // print("DUMPER: Unary", node.module)
    self <<< indent <<< "(unary" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(prefix_operator\n"
      withIndentation { visit(node.op) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(operand\n"
      withIndentation { try visit(node.operand) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: Call) throws {
    // print("DUMPER: Call", node.module)
    self <<< indent <<< "(call" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(callee\n"
      withIndentation { try visit(node.callee) }
      self <<< ")"
      if !node.arguments.isEmpty {
        self <<< "\n" <<< indent <<< "(arguments\n"
        withIndentation { try visit(node.arguments) }
        self <<< ")"
      }
    }
    self <<< ")"
  }

  public func visit(_ node: Arg) {
    // print("DUMPER: Arg", node.module)
    self <<< indent <<< "(arg" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " '" <<< node.label <<< "'"
    self <<< " type='" <<< node.type <<< "'"
    withIndentation {
      self <<< "\n"
      try visit(node.value)
    }
    self <<< ")"
  }

  public func visit(_ node: Tuple) throws {
    // print("DUMPER: Tuple", node.module)
    self <<< indent <<< "(tuple"
    self <<< " type='" <<< node.type <<< "'"
    if let label = node.label {
      self <<< " '\(label)'"
    }
    if !node.elements.isEmpty {
      self <<< "\n"
      withIndentation { try visit(node.elements) }
    }
    self <<< ")"
  }

  public func visit(_ node: TupleElem) throws {
    // print("DUMPER: TupleElem", node.module)
    self <<< indent <<< "(tuple_elem" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " '" <<< node.label <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(value\n"
      withIndentation { try visit(node.value) }
      self <<< ")"
    }
    self <<< ")"
  }

  public func visit(_ node: Select) {
    // print("DUMPER: Select", node.module)
    self <<< indent <<< "(select" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    withIndentation {
      self <<< "\n" <<< indent <<< "(owner\n"
      withIndentation { try visit(node.owner) }
      self <<< ")"
      self <<< "\n" <<< indent <<< "(ownee '\(node.ownee)')"
    }
    self <<< ")"
  }

  public func visit(_ node: Ident) {
    // print("DUMPER: Ident", node.module)
    self <<< indent <<< "(ident '\(node.name)'" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " symbol='" <<< node.symbol?.name <<< ", " <<< node.symbol?.type <<< " '"
    self <<< " type='" <<< node.type <<< "'"
    self <<< " scope='" <<< node.scope <<< "'"
    self <<< " scopeid='" <<< node.scope?.id <<< "'"
    self <<< ")"
  }

  public func visit(_ node: Scalar<Bool>) {
    // print("DUMPER: Scalar", node.module)
    self <<< indent <<< "(scalar \(node.value)" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    self <<< ")"
  }

  public func visit(_ node: Scalar<Int>) {
    // print("DUMPER: Scalar", node.module)
    self <<< indent <<< "(scalar \(node.value)" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    self <<< ")"
  }

  public func visit(_ node: Scalar<Double>) {
    // print("DUMPER: Scalar", node.module)
    self <<< indent <<< "(scalar \(node.value)" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    self <<< ")"
  }

  public func visit(_ node: Scalar<String>) {
    // print("DUMPER: Scalar", node.module)
    self <<< indent <<< "(scalar \"\(node.value)\"" <<< " <module : " <<< node.module
      .innerScope <<< " (" <<< node.module.range <<< ") " <<< node.module.statements
      .count <<< ">"
    self <<< " type='" <<< node.type <<< "'"
    self <<< ")"
  }

  public func visit(_ nodes: [Node]) throws {
    for node in nodes {
      try visit(node)
      if node != nodes.last {
        self <<< "\n"
      }
    }
  }

  // Fileprivate

  @discardableResult
  fileprivate static func <<< <T>(dumper: ASTDumper, item: T) -> ASTDumper {
    dumper.outputStream.write(String(describing: item))
    return dumper
  }

  @discardableResult
  fileprivate static func <<< <T>(dumper: ASTDumper, item: T?) -> ASTDumper {
    dumper.outputStream.write(item.map { String(describing: $0) } ?? "_")
    return dumper
  }

  fileprivate func withIndentation(body: () throws -> Void) {
    level += 1
    try! body()
    level -= 1
  }

  // Private

  private var level: Int = 0

  private var indent: String {
    String(repeating: "  ", count: level)
  }
}
