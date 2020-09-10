import AST
import Utils

/// Transformer that normalizes the AST representation.
public final class Replace: ASTTransformer {
  // Lifecycle

  public init(replace: [String: Value], replaceLambda: [String: String], type: Bool) {
    self.replace = replace
    typeOnly = type
    self.replaceLambda = replaceLambda
  }

  // Public

  public var typeOnly: Bool
  public let replace: [String: Value]
  public let replaceLambda: [String: String]
  public var evalContext: EvaluationContext = [:]

  /* public var context: [Func: EvaluationContext] = [:] */

  /* public var replace: [String : Expr] { */
  /*     get { */
  /*         return replace */
  /*     } */
  /*     set(new) { */
  /*         replace = new */
  /*     } */
  /* } */

  public func transform(_ node: Binary) throws -> Node {
    Call(
      callee: node.op,
      arguments: [
        Arg(
          label: nil,
          value: try transform(node.left) as! Expr,
          module: node.left.module,
          range: node.left.range
        ),
        Arg(
          label: nil,
          value: try transform(node.right) as! Expr,
          module: node.right.module,
          range: node.right.range
        ),
      ],
      module: node.module,
      range: node.range
    )
  }

  public func transform(_ node: Unary) throws -> Node {
    Call(
      callee: node.op,
      arguments: [
        Arg(
          label: nil,
          value: try transform(node.operand) as! Expr,
          module: node.operand.module,
          range: node.operand.range
        ),
      ],
      module: node.module,
      range: node.range
    )
  }

  /* public func transform(_ node: Call) throws -> Node { */
  /*   node.arguments = try node.arguments.map(transform) as! [Arg] */
  /*   switch node.callee { */
  /*   case let n as Ident: */
  /*     if let new = replace[n.name] { */
  /*       node.callee = try transform(node.callee) as! Expr */
  /*       let owo = eval() */
  /*     } */
  /*   default: */
  /*     node.callee = try transform(node.callee) as! Expr */
  /*     break */
  /*   } */
  /*   return node */
  /* } */

  public func transform(_ node: Ident) throws -> Node {
    if let new = replace[node.name] {
      // print("rippppppppppppppppppppppppp", node.name)
      switch new {
      case .int:
        return Scalar<Int>(
          value: new.swiftValue as! Int,
          module: node.module,
          range: node.range
        )
      case .tuple(let e, _, _):
        return Tuple(
          label: e.label,
          elements: e.elements,
          module: node.module,
          range: e.range
        )
        return e
      case .function(var f, let closure):
        /* return node */
        return Func(
          name: replaceLambda[node.name],
          signature: f.signature,
          body: f.body,
          module: f.module,
          range: f.range
        )
        if typeOnly == true {
          // print("hmmmmmmmmmmmmmm")
          node.type = f.type
          return node
        }
        /* evalContext.merge(closure.copy, uniquingKeysWith: { _, rhs in rhs }) */
        /* closure.forEach { */
        /*   print("hahahaha", $0.key.scope.symbols.count) */
        /*   assertionFailure() */
        /*   [> f.scope?.symbols[$0.key.scope] = $0.key <] */
        /* } */

        let owo = f.copy()
        owo.name = replaceLambda[node.name]!
        // String(node.name)
        return owo

      /* return issou */
      default:
        assertionFailure()
        let owo = node.copy()
        owo.name = replaceLambda[node.name]!
        return owo
      }
    }
    return node
  }

  // Fileprivate

  fileprivate static var nextID = 0
}
