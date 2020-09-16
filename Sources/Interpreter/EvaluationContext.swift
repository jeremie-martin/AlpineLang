import AST

public final class EvaluationContext {
  // Lifecycle

  public init(_ dictionary: [Symbol: Value]) {
    storage = dictionary
  }

  public init<S>(uniqueKeysWithValues keysAndValues: S)
    where S: Sequence, S.Element == (Symbol, Value)
  {
    storage = Dictionary(uniqueKeysWithValues: keysAndValues)
  }

  public init<S>(
    _ keysAndValues: S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  )
    rethrows
    where S: Sequence, S.Element == (Symbol, Value) {
    storage = try Dictionary(keysAndValues, uniquingKeysWith: combine)
  }

  // Public

  public var storage: [Symbol: Value]
  public var replace: [String: Value] = [:]

  public var copy: EvaluationContext {
    EvaluationContext(storage)
  }

  public func merge(
    _ other: EvaluationContext,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows {
    try storage.merge(other.storage, uniquingKeysWith: combine)
  }

  public func merging(
    _ other: EvaluationContext,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> EvaluationContext {
    try EvaluationContext(storage.merging(other.storage, uniquingKeysWith: combine))
  }

  public subscript(symbol: Symbol) -> Value? {
    get { storage[symbol] }
    set { storage[symbol] = newValue }
  }
}

extension EvaluationContext: Collection {
  public typealias Index = Dictionary<Symbol, Value>.Index
  public typealias Element = Dictionary<Symbol, Value>.Element

  public var startIndex: Index {
    storage.startIndex
  }

  public var endIndex: Index {
    storage.endIndex
  }

  public func index(after i: Index) -> Index {
    storage.index(after: i)
  }

  public subscript(i: Index) -> Element {
    storage[i]
  }
}

extension EvaluationContext: ExpressibleByDictionaryLiteral {
  public convenience init(dictionaryLiteral elements: (Symbol, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}

extension EvaluationContext: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    storage.description
  }

  public var debugDescription: String {
    storage.debugDescription
  }
}

extension EvaluationContext: CustomReflectable {
  public var customMirror: Mirror {
    storage.customMirror
  }
}
