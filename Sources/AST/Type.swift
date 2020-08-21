/// Base class for all types in Alpine.
public class TypeBase: Hashable, CustomStringConvertible {
  public func copy() -> TypeBase {
		// print("TypeBase")
    return self
  }

  fileprivate init() {
  }

  /// The metatype of the type.
  public lazy var metatype: Metatype = { [unowned self] in
    return Metatype(of: self)
  }()

  public var hashValue: Int {
    return 0
  }

  public var description: String {
    var memo = Set<TupleType>()
    return serialize(memo: &memo)
  }

  public static func == (lhs: TypeBase, rhs: TypeBase) -> Bool {
    return lhs === rhs
  }

  fileprivate func serialize(memo: inout Set<TupleType>) -> String {
    return String(describing: self)
  }

}

/// Class to represent the description of a type.
public final class Metatype: TypeBase {
  override public func copy() -> Metatype {
		print("Metatype")
    print("so", self.type)
    let m = Metatype(of: self.type.copy())
    return m
  }

  fileprivate init(of type: TypeBase) {
    self.type = type
  }

  public let type: TypeBase

  fileprivate override func serialize(memo: inout Set<TupleType>) -> String {
    return "\(type.serialize(memo: &memo)).metatype"
  }

}

/// A special type that's used to represent a typing failure.
public final class ErrorType: TypeBase {
  override public func copy() -> ErrorType {
    print("ErrorType")
    return self
  }

  public static let get = ErrorType()

  fileprivate override func serialize(memo: inout Set<TupleType>) -> String {
    return "<error type>"
  }

}

/// Class to represent the built-in types.
public final class BuiltinType: TypeBase {
  override public func copy() -> BuiltinType {
		print("BuiltinType")
    return BuiltinType(name: String(self.name))
  }

  private init(name: String) {
    self.name = name
  }

  public let name: String

  public override var hashValue: Int {
    return name.hashValue
  }

  fileprivate override func serialize(memo: inout Set<TupleType>) -> String {
    return name
  }

  public static let bool   = BuiltinType(name: "Bool")
  public static let int    = BuiltinType(name: "Int")
  public static let float  = BuiltinType(name: "Float")
  public static let string = BuiltinType(name: "String")

}

/// A type variable used during type checking.
public final class TypeVariable: TypeBase {
  override public func copy() -> TypeVariable {
		// print("TypeVariable")
    TypeVariable.nextID -= 1
    var v = TypeVariable()
    v.id = Int(self.id)
    return v
  }

  public override init() {
    self.id = TypeVariable.nextID
    TypeVariable.nextID += 1
  }

  public var id: Int
  private static var nextID = 0

  public override var hashValue: Int {
    return id
  }

  fileprivate override func serialize(memo: inout Set<TupleType>) -> String {
    return "$\(id)"
  }

}

/// Class to represent function types.
public final class FunctionType: TypeBase {
  override public func copy() -> FunctionType {
    print("FunctionType")
    return FunctionType(domain: self.domain.copy(), codomain: self.codomain.copy())
  }

  internal init(domain: TupleType, codomain: TypeBase) {
    self.domain = domain
    self.codomain = codomain
  }

  /// The domain of the function.
  public let domain: TupleType
  /// The codomain of the function.
  public let codomain: TypeBase

  fileprivate override func serialize(memo: inout Set<TupleType>) -> String {
    return "\(domain.serialize(memo: &memo)) -> \(codomain.serialize(memo: &memo))"
  }

}

/// Class to represent tuple types.
public final class TupleType: TypeBase {
  override public func copy() -> TupleType {
    print("TupleType")
    return TupleType(label: (self.label != nil) ? String(label!) : nil, elements: self.elements.map { $0.copy() })
  }

  public init(label: String?, elements: [TupleTypeElem]) {
    self.label = label
    self.elements = elements
  }

  /// The label of the type.
  public let label: String?
  /// The elements of the type.
  public var elements: [TupleTypeElem]

  fileprivate override func serialize(memo: inout Set<TupleType>) -> String {
    guard !memo.contains(self)
      else { return "..." }
    memo.insert(self)

    guard (self.label != nil) || (!self.elements.isEmpty)
      else { return "()" }

    let elements = self.elements
      .map({ ($0.label ?? "_") + ": \($0.type.serialize(memo: &memo))" })
      .joined(separator: ", ")

    let label = self.label.map { "#\($0)" } ?? ""
    let trailer = elements.isEmpty ? "" : "(\(elements))"

    return label + trailer
  }

  public static func == (lhs: TupleType, rhs: TupleType) -> Bool {
    return (lhs.label == rhs.label) && (lhs.elements == rhs.elements)
  }

}

/// The element of a tuple type.
public struct TupleTypeElem: Equatable, CustomStringConvertible {
  public func copy() -> TupleTypeElem {
		print("TupleTypeElem")
    print(self, self.label, self.type)
    return TupleTypeElem(label: (self.label != nil) ? String(label!) : nil, type: self.type.copy())
  }

  public init(label: String?, type: TypeBase) {
    self.label = label
    self.type = type
  }

  public let label: String?
  public let type: TypeBase

  public var description: String {
    return "\(label ?? "_"): \(type)"
  }

  public static func == (lhs: TupleTypeElem, rhs: TupleTypeElem) -> Bool {
    return (lhs.label == rhs.label) && (lhs.type == rhs.type)
  }

}

extension Set {
    func setmap<U>(transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.map(transform))
    }
}

/// Class to represent union types.
public final class UnionType: TypeBase {
  override public func copy() -> UnionType {
		print("UnionType")

    /* for t in self.cases { */
    /*     print("- ", t) */
    /* } */
    /* print() */
    return UnionType(cases: try self.cases.setmap { $0 })
  }

  internal init(cases: Set<TypeBase>) {
    self.cases = cases
  }

  public let cases: Set<TypeBase>

  fileprivate override func serialize(memo: inout Set<TupleType>) -> String {
    let cases = self.cases
      .map({ $0.serialize(memo: &memo) })
      .joined(separator: " or ")
    return "( \(cases) )"
  }


  public static func == (lhs: UnionType, rhs: UnionType) -> Bool {
    return lhs.cases == rhs.cases
  }

}
