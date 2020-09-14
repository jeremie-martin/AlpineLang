import AST

/// Enumerates the kinds of tokens.
public enum TokenKind: String {
  // MARK: Literals

  case bool
  case integer
  case float
  case string

  // MARK: Identifiers

  case identifier
  case underscore

  // MARK: Operators

  case not
  case and
  case or
  case add
  case sub
  case mul
  case div
  case mod
  case lt
  case le
  case ge
  case gt
  case eq
  case ne
  case arrow
  case thickArrow

  case dot
  case comma
  case colon
  case doubleColon
  case semicolon
  case sharp
  case exclamationMark
  case questionMark
  case ellipsis
  case newline
  case eof

  case leftParen
  case rightParen
  case leftBrace
  case rightBrace
  case leftBracket
  case rightBracket

  // MARK: Keywords

  case `let`
  case `func`
  case type
  case `if`
  case then
  case `else`
  case match
  case with

  // MARK: Error tokens

  case unknown
  case unterminatedBlockComment
  case unterminatedStringLiteral
}

/// Represents a token.
public struct Token {
  // Lifecycle

  public init(kind: TokenKind, value: String? = nil, range: SourceRange) {
    self.kind = kind
    self.value = value
    self.range = range
  }

  // Public

  /// The kind of the token.
  public let kind: TokenKind
  /// The optional value of the token.
  public let value: String?
  /// The range of characters that compose the token in the source file.
  public let range: SourceRange

  /// Whether or not the token is a statement delimiter.
  public var isStatementDelimiter: Bool {
    kind == .newline || kind == .semicolon
  }

  /// Whether or not the token is an prefix operator.
  public var isPrefixOperator: Bool {
    asPrefixOperator != nil
  }

  /// The token as a prefix operator.
  public var asPrefixOperator: PrefixOperator? {
    PrefixOperator(rawValue: kind.rawValue)
  }

  /// Whether or not the token is an infix operator.
  public var isInfixOperator: Bool {
    asInfixOperator != nil
  }

  /// The token as an infix operator.
  public var asInfixOperator: InfixOperator? {
    InfixOperator(rawValue: kind.rawValue)
  }

  /// Whether or not the token can represent a label.
  public var isLabel: Bool {
    [.identifier, .not, .and, .or, .let, .func, .type, .if, .then, .else, .match, .with]
      .contains(kind)
  }

  /// The token as a label value.
  public var asLabel: String? {
    guard isLabel
    else { return nil }
    return kind == .identifier
      ? value
      : kind.rawValue
  }
}

extension Token: Equatable {
  public static func == (lhs: Token, rhs: Token) -> Bool {
    (lhs.kind == rhs.kind) && (lhs.value == rhs.value) && (lhs.range == rhs.range)
  }
}

extension Token: Hashable {
  public func hash(into hasher: inout Hasher) {
    if let label = asLabel {
      hasher.combine(label)
    } else {
      hasher.combine(kind)
    }
  }
}

extension Token: CustomStringConvertible {
  public var description: String {
    kind.rawValue
  }
}
