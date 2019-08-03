//
//  EditorViewWrapper.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/27/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import Combine
import SavannaKit
import GodBolt

final class EditorViewController: UIViewController {
  let text: String
  let language: Language?
  let onTextChange: (SyntaxTextView) -> Void

  init(text: String, language: Language?, onTextChange: @escaping (SyntaxTextView) -> Void) {
    self.text = text
    self.language = language
    self.onTextChange = onTextChange
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    let syntaxView = SyntaxTextView(frame: .zero, lexer: TokenizingLexer<CToken>(), didChangeText: self.onTextChange)
    syntaxView.text = self.text
    guard let language = self.language else {
      return
    }
    guard
      let lexer = lexerForLanguage[language],
      let theme = themeForLanguage[language]
    else {
      return
    }
    syntaxView.theme = theme
    syntaxView.lexer = lexer
    self.view = syntaxView
  }
}

private let lexerForLanguage: [Language: Lexer] = [
  .c: TokenizingLexer<CToken>(),
  .fortran: TokenizingLexer<CToken>(),
  .cpp: TokenizingLexer<CppToken>(),
  .cppx: TokenizingLexer<CppToken>(),
  .assembly: TokenizingLexer<AssemblyToken>(),
  .cuda: TokenizingLexer<CToken>(),
  .llvm: TokenizingLexer<CToken>(),
  .d: TokenizingLexer<CToken>(),
  .ispc: TokenizingLexer<CToken>(),
  .analysis: TokenizingLexer<CToken>(),
  .go: TokenizingLexer<CToken>(),
  .rust: TokenizingLexer<CToken>(),
  .clean: TokenizingLexer<CToken>(),
  .pascal: TokenizingLexer<CToken>(),
  .haskell: TokenizingLexer<CToken>(),
  .ada: TokenizingLexer<CToken>(),
  .ocaml: TokenizingLexer<CToken>(),
  .swift: TokenizingLexer<SwiftToken>(),
  .zig: TokenizingLexer<CToken>(),
]

private let themeForLanguage: [Language: SyntaxColorTheme] = [
  .c: UniversalTheme<CToken>(),
  .fortran: UniversalTheme<CToken>(),
  .cpp: UniversalTheme<CppToken>(),
  .cppx: UniversalTheme<CppToken>(),
  .assembly: UniversalTheme<AssemblyToken>(),
  .cuda: UniversalTheme<CToken>(),
  .llvm: UniversalTheme<LLVMToken>(),
  .d: UniversalTheme<CToken>(),
  .ispc: UniversalTheme<CToken>(),
  .analysis: UniversalTheme<CToken>(),
  .go: UniversalTheme<CToken>(),
  .rust: UniversalTheme<CToken>(),
  .clean: UniversalTheme<CToken>(),
  .pascal: UniversalTheme<CToken>(),
  .haskell: UniversalTheme<CToken>(),
  .ada: UniversalTheme<CToken>(),
  .ocaml: UniversalTheme<CToken>(),
  .swift: UniversalTheme<SwiftToken>(),
  .zig: UniversalTheme<CToken>(),
]

