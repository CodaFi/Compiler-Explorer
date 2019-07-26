///
///  SwiftLexer.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import SavannaKit

// FIXME: All the lexers need to be consolidated.
class SwiftLexer: Lexer {

  init() {}

  func getSavannaTokens(input: String) -> [Token] {
    var tokens = [SwiftToken]()

    input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) { (word, range, _, _) in
      guard let word = word else {
        return
      }

      let type: SwiftTokenType
      if keywordSet.contains(word) {
        type = .keyword
      } else if word.starts(with: "#") {
        type = .poundLiteral
      } else if word.starts(with: "@") {
        type = .directive
      } else {
        type = .plainText
      }

      tokens.append(SwiftToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range))
    }
    return tokens
  }
}

enum SwiftTokenType {
  case keyword
  case poundLiteral
  case directive
  case plainText
}

struct SwiftToken: Token {
  let type: SwiftTokenType
  let isEditorPlaceholder: Bool
  let isPlain: Bool
  let range: Range<String.Index>
}

private let keywordSet: Set<String> = [
  // Decl Keywords
    "associatedtype",
    "class",
    "deinit",
    "enum",
    "extension",
    "func",
    "import",
    "init",
    "inout",
    "let",
    "operator",
    "precedencegroup",
    "protocol",
    "struct",
    "subscript",
    "typealias",
    "var",

    "fileprivate",
    "internal",
    "private",
    "public",
    "static",

    // Statement keywords
    "defer",
    "if",
    "guard",
    "do",
    "repeat",
    "else",
    "for",
    "in",
    "while",
    "return",
    "break",
    "continue",
    "fallthrough",
    "switch",
    "case",
    "default",
    "where",
    "catch",
    "throw",

    // Expression keywords
    "as",
    "Any",
    "false",
    "is",
    "nil",
    "rethrows",
    "super",
    "self",
    "Self",
    "true",
    "try",
    "throws",

    "__FILE__",
    "__LINE__",
    "__COLUMN__",
    "__FUNCTION__",
    "__DSO_HANDLE__",

    "yield",
]

class SwiftTheme: SyntaxColorTheme {

  private static var lineNumbersColor: PlatformColor {
    return PlatformColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
  }

  let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: PlatformFont(name: "Menlo", size: 16)!, textColor: lineNumbersColor)
  let gutterStyle: GutterStyle = GutterStyle(backgroundColor: PlatformColor(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0), minimumWidth: 32)

  let font = PlatformFont(name: "Menlo", size: 15)!

  let backgroundColor = PlatformColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)

  func globalAttributes() -> [NSAttributedString.Key: Any] {

    var attributes = [NSAttributedString.Key: Any]()

    attributes[.font] = PlatformFont(name: "Menlo", size: 15)!
    attributes[.foregroundColor] = PlatformColor.white

    return attributes
  }

  func attributes(for token: Token) -> [NSAttributedString.Key: Any] {

    guard let myToken = token as? SwiftToken else {
      return [:]
    }

    var attributes = [NSAttributedString.Key: Any]()

    switch myToken.type {
    case .keyword:
      attributes[.foregroundColor] = PlatformColor.systemPink
    case .poundLiteral:
      attributes[.foregroundColor] = PlatformColor.brown
    case .directive:
      attributes[.foregroundColor] = PlatformColor.systemPink
    case .plainText:
      attributes[.foregroundColor] = PlatformColor.white
    }

    return attributes
  }

}
