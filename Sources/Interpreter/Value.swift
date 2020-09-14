import AST
import Parser
import Sema

public struct TupleWrapper: Hashable {
  // Public

  public static func == (lhs: TupleWrapper, rhs: TupleWrapper) -> Bool {
    lhs.source == rhs.source && lhs.replace == rhs.replace
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(source)
    hasher.combine(replace)
  }

  // Internal

  let source: String
  let replace: [String: Value]
}

public final class ValueFactory {
  public var context: [(Value, Module)] = []
  public var cache: [TupleWrapper: Value] = [:]

  public func dump() {
    let dumper = ASTDumper(outputTo: Console.out)
    switch context[0].0 {
    case .tuple(let a, let b, let c):
      print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
      print(a)
      dumper.dump(ast: context[0].1)
      dumper.dump(ast: a)
    default:
      break
    }
  }
}

public enum Value {
  case bool(Bool) // A boolean value.
  case int(Int) // An integer value.
  case real(Double) // A real value.
  case string(String) // A string value.
  case builtinFunction(([Any]) -> Any) // A built-in function.
  case function(Func, closure: EvaluationContext) // A user function.
  case tuple(
    expr: Tuple,
    label: String?,
    elements: [(label: String?, value: Value)]
  ) // A tuple.
}

extension Value: Equatable {
  public static func == (lhs: Value, rhs: Value) -> Bool {
    switch (lhs, rhs) {
    case (.bool(let a), .bool(let b)):
      return a == b
    case (.int(let a), .int(let b)):
      return a == b
    case (.real(let a), .real(let b)):
      return a == b
    case (.string(let a), .string(let b)):
      return a == b
    case (.function(let fa, let ca), .function(let fb, let cb)):
      return fa == fb && ca.storage.keys == cb.storage.keys
    case (.tuple(let exA, let lA, let elA), .tuple(let exB, let lB, let elB)):
      if exA.label != exB.label, elA.count != elB.count {
        return false
      }
      if elA.isEmpty {
        return true
      }
      for i in 0 ... elA.count - 1 {
        if elA[i].value != elB[i].value {
          return false
        }
      }
      return true
    default:
      return false
    }
  }
}

extension Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .bool(let v):
      hasher.combine(v)
    case .int(let v):
      hasher.combine(v)
    case .real(let v):
      hasher.combine(v)
    case .string(let v):
      hasher.combine(v)
    case .function(let a, let c):
      hasher.combine(a.name)
      hasher.combine(a.type)
      hasher.combine(a.scope)
    case .tuple(let a, let l, let el):
      hasher.combine(a.label)
      hasher.combine(a.type)
    default:
      break
    }
  }
}

extension Value {
  /// Create an alpine value from a Swift native value.
  init?(value: Any) {
    switch value {
    case let v as Bool: self = .bool(v)
    case let v as Int: self = .int(v)
    case let v as Double: self = .real(v)
    case let v as String: self = .string(v)
    default: return nil
    }
  }

  /// Return the Swift value corresponding to this Alpine value, assuming it is representable as a
  /// Swift native type (e.g. `Int`).
  var swiftValue: Any? {
    switch self {
    case .bool(let value): return value
    case .int(let value): return value
    case .real(let value): return value
    case .string(let value): return value
    default: return nil
    }
  }
}

extension Value: CustomStringConvertible {
  public var description: String {
    switch self {
    case .bool(let value):
      return value.description

    case .int(let value):
      return value.description

    case .real(let value):
      return value.description

    case .string(let value):
      return value

    case .builtinFunction:
      return "<built-in function>"

    case .function(let f, closure: _):
      /* return f.name! */
      /* print(f.body.type) */
      /* let name = (f.name != nil) ? f.name! : "" */
      return "<\(f.name!) \(f.type!)>"

    case .tuple(_, let label, let elements):
      guard (label != nil) || (!elements.isEmpty)
      else { return "()" }
      let elts = elements
        .map { $0.label != nil ? "#\($0.label!): \($0.value)" : $0.value.description }
        .joined(separator: ", ")
      let prefix = label.map { "#\($0)" } ?? ""
      let suffix = elements.isEmpty ? "" : "(\(elts))"
      return prefix + suffix
    }
  }
}
