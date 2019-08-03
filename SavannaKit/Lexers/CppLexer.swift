//.
//.  CppLexer.swift
//.  SavannaKit
//.
//.  Created by Robert Widmann on 8/3/19.
//.  Copyright © 2019 CodaFi. All rights reserved.
//.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.
#if os(iOS)
  import UIKit
#else
  import AppKit
#endif

public struct CppToken: UniversalToken {
  public enum CppTokenType {
    case keyword
    case plainText
  }

  public let type: CppTokenType
  public let isEditorPlaceholder: Bool
  public let isPlain: Bool
  public let range: Range<String.Index>

  public static func formToken(_ word: String, in range: Range<String.Index>) -> CppToken {
    let type: CppToken.TokenType
    if keywordSet.contains(word) {
      type = .keyword
    } else {
      type = .plainText
    }
    return CppToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
  }

  public func foregroundColor(for type: CppTokenType) -> PlatformColor {
    switch type {
    case .keyword: return PlatformColor.systemPink
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
        case .dark: return PlatformColor.white
        case .light: return PlatformColor.black
        default: return PlatformColor.white
        }
      #endif
    }
  }
}

private let keywordSet: Set<String> = [
  "alignas",
  "alignof",
  "and",
  "and_eq",
  "asm",
  "auto",
  "bitand",
  "bitor",
  "bool",
  "break",
  "case",
  "catch",
  "char",
  "char8_t",
  "char16_t",
  "char32_t",
  "class",
  "compl",
  "concept",
  "const",
  "consteval",
  "constexpr",
  "const_cast",
  "continue",
  "co_await",
  "co_return",
  "co_yield",
  "decltype",
  "default",
  "delete",
  "do",
  "double",
  "dynamic_cast",
  "else",
  "enum",
  "explicit",
  "export",
  "extern",
  "false",
  "float",
  "for",
  "friend",
  "goto",
  "if",
  "inline",
  "int",
  "long",
  "mutable",
  "namespace",
  "new",
  "noexcept",
  "not",
  "not_eq",
  "nullptr",
  "operator",
  "or",
  "or_eq",
  "private",
  "protected",
  "public",
  "register",
  "reinterpret_cast",
  "requires",
  "return",
  "short",
  "signed",
  "sizeof",
  "static",
  "static_assert",
  "static_cast",
  "struct",
  "switch",
  "template",
  "this",
  "thread_local",
  "throw",
  "true",
  "try",
  "typedef",
  "typeid",
  "typename",
  "union",
  "unsigned",
  "using",
  "virtual",
  "void",
  "volatile",
  "wchar_t",
  "while",
  "xor",
  "xor_eq",
]
