import AST
import Utils

/// Transformer that normalizes the AST representation.
public final class Normalizer: ASTTransformer {

  public init() {
  }

  public var replace: [String : Expr] = [:]
  /* public var replace: [String : Expr] { */
  /*     get { */
  /*         return replace */
  /*     } */
  /*     set(new) { */
  /*         replace = new */
  /*     } */
  /* } */

  public func transform(_ node: Binary) throws -> Node {
    return Call(
      callee: node.op,
      arguments: [
        Arg(
          label : nil,
          value : try transform(node.left) as! Expr,
          module: node.left.module,
          range : node.left.range),
        Arg(
          label : nil,
          value : try transform(node.right) as! Expr,
          module: node.right.module,
          range : node.right.range),
      ],
      module: node.module,
      range : node.range)
  }

  public func transform(_ node: Unary) throws -> Node {
    return Call(
      callee: node.op,
      arguments: [
        Arg(
          label : nil,
          value : try transform(node.operand) as! Expr,
          module: node.operand.module,
          range : node.operand.range),
      ],
      module: node.module,
      range : node.range)
  }

  public func transform(_ node: Call) throws -> Node {
    switch node.callee {
    case let n as Ident:

        let nn = node.copy()

        if let new = replace[n.name] {
          print("SOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
          print("SOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
          print("SOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO")
          print("\n")
          nn.callee = new.copy()
        }
        let dumper = ASTDumper(outputTo: Console.out)
        dumper.dump(ast: nn)

        nn.callee = try transform(nn.callee) as! Expr
        nn.arguments = try nn.arguments.map(transform) as! [Arg]
        return nn
    default:
      node.callee = try transform(node.callee) as! Expr
      node.arguments = try node.arguments.map(transform) as! [Arg]
      return node
    }
    /* return nn */
  }

  public func transform(_ node: Ident) throws -> Node {
    if let new = replace[node.name] {
      print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
      let dumper = ASTDumper(outputTo: Console.out)
      dumper.dump(ast: new)
      print(new.module)
      print("hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
      let owo = new.copy()
      return owo
    }
    return node
  }
}
