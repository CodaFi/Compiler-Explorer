///
///  CLexer.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import SavannaKit

// FIXME: All the lexers need to be consolidated.
class CLexer: Lexer {

  init() {}

  func getSavannaTokens(input: String) -> [Token] {
    var tokens = [CToken]()

    input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) { (word, range, _, _) in
      guard let word = word else {
        return
      }

      let type: CTokenType
      if keywordSet.contains(word) {
        type = .keyword
      } else {
        type = .plainText
      }

      tokens.append(CToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range))
    }
    return tokens
  }
}

enum CTokenType {
  case keyword
  case plainText
}

struct CToken: Token {
  let type: CTokenType
  let isEditorPlaceholder: Bool
  let isPlain: Bool
  let range: Range<String.Index>
}

private let keywordSet: Set<String> = [
  "auto",
  "break",
  "case",
  "char",
  "const",
  "continue",
  "default",
  "do",
  "double",
  "else",
  "enum",
  "extern",
  "float",
  "for",
  "goto",
  "if",
  "int",
  "long",
  "register",
  "return",
  "short",
  "signed",
  "sizeof",
  "static",
  "struct",
  "switch",
  "typedef",
  "union",
  "unsigned",
  "void",
  "volatile",
  "while",
]

class CTheme: SyntaxColorTheme {

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

    guard let myToken = token as? CToken else {
      return [:]
    }

    var attributes = [NSAttributedString.Key: Any]()

    switch myToken.type {
    case .keyword:
      attributes[.foregroundColor] = PlatformColor.systemPink
    case .plainText:
      attributes[.foregroundColor] = PlatformColor.white
    }

    return attributes
  }

}
