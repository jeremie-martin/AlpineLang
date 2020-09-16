/// A named symbol.
public class Symbol {
  // Lifecycle

  internal init(
    name: String, scope: Scope, type: TypeBase?, overloadable: Bool
  ) {
    self.name = name
    self.scope = scope
    self.type = type
    self.overloadable = overloadable
  }

  // Public

  /// The name of the symbol.
  public let name: String
  /// The type of the symbol.
  public var type: TypeBase?
  /// Let function symbols be marked overloadable.
  public let overloadable: Bool
  /// The scope that defines this symbol.

  // TODO:
  /* public unowned var scope: Scope */
  public var scope: Scope
}

extension Symbol: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(scope.id)
    hasher.combine(scope.name)
    hasher.combine(scope.module?.id)
    hasher.combine(type.hashValue)
    hasher.combine(type?.metatype)
    hasher.combine(overloadable)
  }

  public static func == (lhs: Symbol, rhs: Symbol) -> Bool {
    lhs === rhs
  }
}
