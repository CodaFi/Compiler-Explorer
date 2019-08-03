///
///  CLexer.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

#if os(iOS)
import UIKit
#else
import AppKit
#endif

// FIXME: All the lexers need to be consolidated.
public class CLexer: Lexer {

  public init() {}

  public func getSavannaTokens(input: String) -> [Token] {
    var tokens = [CToken]()

    input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) { (word, range, _, _) in
      guard let word = word else {
        return
      }

      let type: CToken.TokenType
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

public struct CToken: UniversalToken {
  public enum CTokenType {
    case keyword
    case plainText
  }

  public let type: CTokenType
  public let isEditorPlaceholder: Bool
  public let isPlain: Bool
  public let range: Range<String.Index>

  public func foregroundColor(for type: CTokenType) -> PlatformColor {
    switch type {
    case .keyword:
      return PlatformColor.systemPink
    case .plainText:
      #if os(macOS)
      let appearanceName = NSApp.effectiveAppearance.name
      if appearanceName == .darkAqua {
        return PlatformColor.white
      } else if appearanceName == .aqua {
        return PlatformColor.black
      } else {
        return PlatformColor.white
      }
      #else
      switch UIScreen.main.traitCollection.userInterfaceStyle {
      case .dark:
        return PlatformColor.white
      case .light:
        return PlatformColor.black
      default:
        return PlatformColor.white
      }
      #endif
    }
  }
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
