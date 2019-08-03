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

#if os(iOS)
  import UIKit
#else
  import AppKit
#endif

public struct SwiftToken: UniversalToken {
  public enum SwiftTokenType {
    case keyword
    case poundLiteral
    case directive
    case plainText
  }
  public let type: SwiftTokenType
  public let isEditorPlaceholder: Bool
  public let isPlain: Bool
  public let range: Range<String.Index>

  public static func formToken(_ word: String, in range: Range<String.Index>) -> SwiftToken {
    let type: SwiftToken.TokenType
    if keywordSet.contains(word) { type = .keyword }
    else if word.starts(with: "#") { type = .poundLiteral }
    else if word.starts(with: "@") { type = .directive }
    else { type = .plainText }
    return SwiftToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
  }

  public func foregroundColor(for type: TokenType) -> PlatformColor {
    switch type {
    case .keyword: return PlatformColor.systemPink
    case .poundLiteral: return PlatformColor.brown
    case .directive: return PlatformColor.systemPink
    case .plainText:
      #if os(macOS)
        let appearanceName = NSApp.effectiveAppearance.name
        if appearanceName == .darkAqua {
          return PlatformColor.white
        } else if appearanceName == .aqua {
          return PlatformColor.black
        }  else {
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
  // Declaration Keywords
  "associatedtype", "class", "deinit", "enum", "extension", "func", "import", "init", "inout",
  "let", "operator", "precedencegroup", "protocol", "struct", "subscript", "typealias", "var",
  "fileprivate", "internal", "private", "public", "static",

  // Statement keywords
  "defer", "if", "guard", "do", "repeat", "else", "for", "in", "while", "return", "break",
  "continue", "fallthrough", "switch", "case", "default", "where", "catch", "throw",

  // Expression keywords
  "as", "Any", "false", "is", "nil", "rethrows", "super", "self", "Self", "true", "try", "throws",
  "__FILE__", "__LINE__", "__COLUMN__", "__FUNCTION__", "__DSO_HANDLE__", "yield",
]
