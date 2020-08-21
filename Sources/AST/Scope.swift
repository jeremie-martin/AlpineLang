/// A mapping from names to symbols.
///
/// This collection stores the symbols that are declared within a scope (e.g. a function scope).
/// It is a mapping `String -> [Symbol]`, as a symbol names may be overloaded.

public class Scope {
  // beware of circular dependance between scope and symbol
  public func copy() -> Scope {
    let n = (self.name != nil) ? String(self.name!) : nil
    // print("------------------------", self.id)
    Scope.nextID -= 1
    let s = Scope(name: n, parent: nil, module: self.module)
    s.id = Int(self.id)
    // print("------------------------", s.id)
    s.symbols = [:]
    // print("BEFORE FOR EACH")
    // print("BEFORE FOR EACH")
    // print("BEFORE FOR EACH")
    self.symbols.forEach { $0.value.map { s.create(name: $0.name, type: $0.type, overloadable: $0.overloadable) }}
    // print("AFTER FOR EACH")
    // print("AFTER FOR EACH")
    // print("AFTER FOR EACH")
    // print("------***------------------------")
    // print(s.module, self.module)
    // print(s.id, self.id)
    // print(s.symbols, self.symbols)
    // print(s == self)
    // print("------+++------------------------")
    if (self.parent != nil) {
      s.parent = self.parent!.copy()
    }

    return s
  }

  public init(name: String? = nil, parent: Scope? = nil, module: Module? = nil) {
    // Create a unique ID for the scope.
    self.id = Scope.nextID
    Scope.nextID += 1
    // print("scope", id, name, module?.id)
    // print("scope", id, name, module?.id)
    // print("scope", id, name, module?.id)

    self.name = name
    self.parent = parent
    self.module = module ?? parent?.module
  }

  /// Returns whether or not a symbol with the given name exists in this scope.
  public func defines(name: String) -> Bool {
    if let symbols = self.symbols[name] {
      return !symbols.isEmpty
    }
    return false
  }

  /// Create a symbol in this scope.
  @discardableResult
  public func create(name: String, type: TypeBase?, overloadable: Bool = false) -> Symbol {
    if symbols[name] == nil {
      symbols[name] = []
    }
    precondition(symbols[name]!.all(satisfy: { $0.overloadable }))
    let symbol = Symbol(name: name, scope: self, type: type, overloadable: overloadable)
    symbols[name]!.append(symbol)
    return symbol
  }

  public weak var parent: Scope?
  public weak var module: Module?

  public var id: Int
  public let name: String?
  public var symbols: [String: [Symbol]] = [:]

  fileprivate static var nextID = 0

}

extension Scope: Hashable {

  public var hashValue: Int {
    return self.id
  }

  public static func == (lhs: Scope, rhs: Scope) -> Bool {
    return lhs.id == rhs.id
  }

}

extension Scope: CustomStringConvertible {

  public var description: String {
    return self.name ?? self.id.description
  }
}
