import AST
import Utils

/// Transformer that normalizes the AST representation.
public final class Replace: ASTTransformer {
  // Lifecycle

  public init(replace: [String: Value], replaceLambda: [String: String]) {
    self.replace = replace
    self.replaceLambda = replaceLambda
  }

  // Public

  public let replace: [String: Value]
  public let replaceLambda: [String: String]
  public var evalContext: EvaluationContext = [:]

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

  public func transform(_ node: Ident) throws -> Node {
    if let new = replace[node.name] {
      switch new {
      case .int(let n):
        return Scalar<Int>(
          value: new.swiftValue as! Int,
          module: node.module,
          range: node.range
        )
      case .bool(let n):
        return Scalar<Bool>(
          value: n,
          module: node.module,
          range: node.range
        )
      case .real(let n):
        return Scalar<Double>(
          value: n,
          module: node.module,
          range: node.range
        )
      case .string(let n):
        return Scalar<String>(
          value: n,
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
      case .function(var f, _):
        return Func(
          name: replaceLambda[node.name],
          signature: f.signature,
          body: f.body,
          module: f.module,
          range: f.range
        )
      default:
        assertionFailure()
        return node
      }
    }
    return node
  }

  // Fileprivate

  fileprivate static var nextID = 0
}
