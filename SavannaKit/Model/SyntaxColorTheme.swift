//
//  SyntaxTheme.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/01/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//
import CoreGraphics
import Foundation

public struct LineNumbersStyle {
  public let font: PlatformFont
  public let textColor: PlatformColor
  public init(font: PlatformFont, textColor: PlatformColor) {
    self.font = font
    self.textColor = textColor
  }
}
public struct GutterStyle {
  public let backgroundColor: PlatformColor
  /// If line numbers are displayed, the gutter width adapts to fit all line numbers.
  /// This specifies the minimum width that the gutter should have at all times,
  /// regardless of any line numbers.
  public let minimumWidth: CGFloat
  public init(backgroundColor: PlatformColor, minimumWidth: CGFloat) {
    self.backgroundColor = backgroundColor
    self.minimumWidth = minimumWidth
  }
}
public protocol SyntaxColorTheme {
  /// Nil hides line numbers.
  var lineNumbersStyle: LineNumbersStyle? { get }
  var gutterStyle: GutterStyle { get }
  var font: PlatformFont { get }
  var backgroundColor: PlatformColor { get }
  func globalAttributes() -> [NSAttributedString.Key: Any]
  func attributes(for token: Token) -> [NSAttributedString.Key: Any]
}
