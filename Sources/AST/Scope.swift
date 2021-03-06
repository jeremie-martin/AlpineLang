/// A mapping from names to symbols.
///
/// This collection stores the symbols that are declared within a scope (e.g. a function scope).
/// It is a mapping `String -> [Symbol]`, as a symbol names may be overloaded.

public class Scope {
  // Lifecycle

  public init(name: String? = nil, parent: Scope? = nil, module: Module? = nil) {
    // Create a unique ID for the scope.
    id = Scope.nextID
    Scope.nextID += 1

    self.name = name
    self.parent = parent
    self.module = module ?? parent?.module
  }

  // Public

  public weak var parent: Scope?
  public weak var module: Module?

  public var id: Int
  public let name: String?
  public var symbols: [String: [Symbol]] = [:]

  /// Returns whether or not a symbol with the given name exists in this scope.
  public func defines(name: String) -> Bool {
    if let symbols = self.symbols[name] {
      return !symbols.isEmpty
    }
    return false
  }

  /// Create a symbol in this scope.
  @discardableResult
  public func create(
    name: String,
    type: TypeBase?,
    overloadable: Bool = false
  ) -> Symbol {
    if symbols[name] == nil {
      symbols[name] = []
    }
    precondition(symbols[name]!.all(satisfy: { $0.overloadable }))
    let symbol = Symbol(name: name, scope: self, type: type, overloadable: overloadable)
    symbols[name]!.append(symbol)
    return symbol
  }

  // Fileprivate

  fileprivate static var nextID = 0
}

extension Scope: Hashable {
  public var hashValue: Int {
    id
  }

  public static func == (lhs: Scope, rhs: Scope) -> Bool {
    lhs.id == rhs.id
  }
}

extension Scope: CustomStringConvertible {
  public var description: String {
    name ?? id.description
  }
}
