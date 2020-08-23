/// A named symbol.
public class Symbol {
  public func copy(scope: Scope? = nil) -> Symbol {
    // print(scope)
    let _scope = (scope != nil) ? scope : self.scope.copy()

    /* print("Symbol") */
    /* print(self.name) */
    /* print(self.scope) */

    let s = Symbol(name: String(self.name), scope: _scope!, type: self.type?.copy(), overloadable: self.overloadable)
    // print("scooooooooooooope", _scope)
    // print("scopessssssssssss", s.scope)
    /* print(self.name) */
    /* print(self.scope) */
    /* print(s.name) */
    /* print(s.scope) */
    /* print("End Symbol") */
    /* print("pppppppppppppppppppp", self.scope.id) */
    /* self.scope.symbols.forEach { print($0) } */
    /* s.scope.symbols.forEach { print($0) } */
    /* print("qqqqqqqqqqqqqqqqq", self.scope.id, s.scope.id) */
    return s
  }

  internal init(
    name: String, scope: Scope, type: TypeBase?, overloadable: Bool)
  {
    self.name = name
    self.scope = scope
    self.type = type
    self.overloadable = overloadable
  }

  /// The name of the symbol.
  public let name: String
  /// The type of the symbol.
  public var type: TypeBase?
  /// Let function symbols be marked overloadable.
  public let overloadable: Bool
  /// The scope that defines this symbol.

  // TODO
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
    /* return lhs.hashValue == rhs.hashValue */
    return lhs === rhs
    if(lhs === rhs) {
      // print("??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????")
    }
    if(lhs.name == rhs.name) {
      // print("on est là")
    // print(lhs.name, rhs.name, lhs.hashValue, rhs.hashValue)
    // print(lhs.hashValue == rhs.hashValue)
    // print()
    }
    /* return lhs === rhs */
    return lhs.hashValue == rhs.hashValue
  }

}
