/// Base class for all types in Alpine.
public class TypeBase: Hashable, CustomStringConvertible {
  // Lifecycle

  fileprivate init() {}

  // Public

  /// The metatype of the type.
  public lazy var metatype: Metatype = { [unowned self] in
    Metatype(of: self)
  }()

  public var hashValue: Int {
    0
  }

  public var description: String {
    var memo = Set<TupleType>()
    return serialize(memo: &memo)
  }

  public static func == (lhs: TypeBase, rhs: TypeBase) -> Bool {
    lhs === rhs
  }

  public func copy() -> TypeBase {
    self
  }

  // Fileprivate

  fileprivate func serialize(memo _: inout Set<TupleType>) -> String {
    String(describing: self)
  }
}

/// Class to represent the description of a type.
public final class Metatype: TypeBase {
  // Lifecycle

  fileprivate init(of type: TypeBase) {
    self.type = type
  }

  // Public

  public let type: TypeBase

  override public func copy() -> Metatype {
    let m = Metatype(of: type.copy())
    return m
  }

  // Fileprivate

  override fileprivate func serialize(memo: inout Set<TupleType>) -> String {
    "\(type.serialize(memo: &memo)).metatype"
  }
}

/// A special type that's used to represent a typing failure.
public final class ErrorType: TypeBase {
  // Public

  public static let get = ErrorType()

  override public func copy() -> ErrorType {
    self
  }

  // Fileprivate

  override fileprivate func serialize(memo _: inout Set<TupleType>) -> String {
    "<error type>"
  }
}

/// Class to represent the built-in types.
public final class BuiltinType: TypeBase {
  // Lifecycle

  private init(name: String) {
    self.name = name
  }

  // Public

  public static let bool = BuiltinType(name: "Bool")
  public static let int = BuiltinType(name: "Int")
  public static let float = BuiltinType(name: "Float")
  public static let string = BuiltinType(name: "String")

  public let name: String

  override public var hashValue: Int {
    name.hashValue
  }

  override public func copy() -> BuiltinType {
    BuiltinType(name: String(name))
  }

  // Fileprivate

  override fileprivate func serialize(memo _: inout Set<TupleType>) -> String {
    name
  }
}

/// A type variable used during type checking.
public final class TypeVariable: TypeBase {
  // Lifecycle

  override public init() {
    id = TypeVariable.nextID
    TypeVariable.nextID += 1
  }

  // Public

  public var id: Int

  override public var hashValue: Int {
    id
  }

  // Fileprivate

  override fileprivate func serialize(memo _: inout Set<TupleType>) -> String {
    "$\(id)"
  }

  // Private

  private static var nextID = 0
}

/// Class to represent function types.
public final class FunctionType: TypeBase {
  // Lifecycle

  internal init(domain: TupleType, codomain: TypeBase) {
    self.domain = domain
    self.codomain = codomain
  }

  // Public

  /// The domain of the function.
  public let domain: TupleType
  /// The codomain of the function.
  public let codomain: TypeBase

  override public func copy() -> FunctionType {
    FunctionType(domain: domain.copy(), codomain: codomain.copy())
  }

  // Fileprivate

  override fileprivate func serialize(memo: inout Set<TupleType>) -> String {
    "\(domain.serialize(memo: &memo)) -> \(codomain.serialize(memo: &memo))"
  }
}

/// Class to represent tuple types.
public final class TupleType: TypeBase {
  // Lifecycle

  public init(label: String?, elements: [TupleTypeElem]) {
    self.label = label
    self.elements = elements
  }

  // Public

  /// The label of the type.
  public let label: String?
  /// The elements of the type.
  public var elements: [TupleTypeElem]

  public static func == (lhs: TupleType, rhs: TupleType) -> Bool {
    (lhs.label == rhs.label) && (lhs.elements == rhs.elements)
  }

  override public func copy() -> TupleType {
    TupleType(
      label: (label != nil) ? String(label!) : nil,
      elements: elements.map { $0.copy() }
    )
  }

  // Fileprivate

  override fileprivate func serialize(memo: inout Set<TupleType>) -> String {
    guard !memo.contains(self)
    else { return "..." }
    memo.insert(self)

    guard (self.label != nil) || (!self.elements.isEmpty)
    else { return "()" }

    let elements = self.elements
      /* .map({ ($0.label ?? "_") + ": \($0.type.serialize(memo: &memo))" }) */
      .map { "\($0.type.serialize(memo: &memo))" }
      .joined(separator: ", ")

    let label = self.label.map { "#\($0)" } ?? ""
    let trailer = elements.isEmpty ? "" : "(\(elements))"

    return label + trailer
  }
}

/// The element of a tuple type.
public struct TupleTypeElem: Equatable, CustomStringConvertible {
  // Lifecycle

  public init(label: String?, type: TypeBase) {
    self.label = label
    self.type = type
  }

  // Public

  public let label: String?
  public let type: TypeBase

  public var description: String {
    "\(label ?? "_"): \(type)"
  }

  public static func == (lhs: TupleTypeElem, rhs: TupleTypeElem) -> Bool {
    (lhs.label == rhs.label) && (lhs.type == rhs.type)
  }

  public func copy() -> TupleTypeElem {
    TupleTypeElem(label: (label != nil) ? String(label!) : nil, type: type.copy())
  }
}

extension Set {
  func setmap<U>(transform: (Element) -> U) -> Set<U> {
    Set<U>(map(transform))
  }
}

/// Class to represent union types.
public final class UnionType: TypeBase {
  // Lifecycle

  internal init(cases: Set<TypeBase>) {
    self.cases = cases
  }

  // Public

  public let cases: Set<TypeBase>

  public static func == (lhs: UnionType, rhs: UnionType) -> Bool {
    lhs.cases == rhs.cases
  }

  override public func copy() -> UnionType {
    UnionType(cases: try cases.setmap { $0 })
  }

  // Fileprivate

  override fileprivate func serialize(memo: inout Set<TupleType>) -> String {
    let cases = self.cases
      .map { $0.serialize(memo: &memo) }
      .joined(separator: " or ")
    return "( \(cases) )"
  }
}
