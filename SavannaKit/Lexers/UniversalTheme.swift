//
//  UniversalTheme.swift
//  SavannaKit
//
//  Created by Robert Widmann on 8/3/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//
#if os(iOS)
  import UIKit
#else
  import AppKit
#endif
public protocol UniversalToken: Token {
  associatedtype TokenType
  var type: TokenType { get }
  func foregroundColor(for type: TokenType) -> PlatformColor
}
public class UniversalTheme<TokenType: UniversalToken>: SyntaxColorTheme {
  public init() {}
  private static var lineNumbersColor: PlatformColor {
    return PlatformColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
  }
  public let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(
    font: PlatformFont(name: "Menlo", size: 16)!,
    textColor: lineNumbersColor
  )
  public let font = PlatformFont(name: "Menlo", size: 15)!
  public var gutterStyle: GutterStyle {
    #if os(macOS)
      let appearanceName = NSApp.effectiveAppearance.name
      if appearanceName == .darkAqua {
        return GutterStyle(
          backgroundColor: PlatformColor(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0),
          minimumWidth: 32
        )
      } else if appearanceName == .aqua {
        return GutterStyle(
          backgroundColor: PlatformColor(red: 236/255.0, green: 236/255, blue: 236/255, alpha: 1.0),
          minimumWidth: 32
        )
      } else {
        return GutterStyle(
          backgroundColor: PlatformColor(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0),
          minimumWidth: 32
        )
      }
    #else
      switch UIScreen.main.traitCollection.userInterfaceStyle {
      case .dark:
        return GutterStyle(
          backgroundColor: PlatformColor(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0),
          minimumWidth: 32
        )
      case .light:
        return GutterStyle(
          backgroundColor: PlatformColor(red: 236/255.0, green: 236/255, blue: 236/255, alpha: 1.0),
          minimumWidth: 32
        )
      default:
        return GutterStyle(
          backgroundColor: PlatformColor(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0),
          minimumWidth: 32
        )
      }
    #endif
  }
  public var backgroundColor: PlatformColor {
    #if os(macOS)
      let appearanceName = NSApp.effectiveAppearance.name
      if appearanceName == .darkAqua {
        return PlatformColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
      }
      else if appearanceName == .aqua {
        return PlatformColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      } else {
        return PlatformColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
      }
    #else
      switch UIScreen.main.traitCollection.userInterfaceStyle {
      case .dark:
        return PlatformColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
      case .light:
        return PlatformColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      default:
        return PlatformColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)
      }
    #endif
  }
  public func globalAttributes() -> [NSAttributedString.Key: Any] {
    var attributes = [NSAttributedString.Key: Any]()
    attributes[.font] = PlatformFont(name: "Menlo", size: 15)!
    #if os(macOS)
      let appearanceName = NSApp.effectiveAppearance.name
      if appearanceName == .darkAqua {
        attributes[.foregroundColor] = PlatformColor.white
      } else if appearanceName == .aqua {
        attributes[.foregroundColor] = PlatformColor.black
      } else {
        attributes[.foregroundColor] = PlatformColor.white
      }
    #else
      switch UIScreen.main.traitCollection.userInterfaceStyle {
      case .dark:
        attributes[.foregroundColor] = PlatformColor.white
      case .light:
        attributes[.foregroundColor] = PlatformColor.black
      default:
        attributes[.foregroundColor] = PlatformColor.white
      }
    #endif
    return attributes
  }
  public func attributes(for token: Token) -> [NSAttributedString.Key: Any] {
    guard let exactToken = token as? TokenType else { return [:] }
    var attributes = [NSAttributedString.Key: Any]()
    attributes[.foregroundColor] = exactToken.foregroundColor(for: exactToken.type)
    return attributes
  }
}
