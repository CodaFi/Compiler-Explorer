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
    let syntaxView = SyntaxTextView(frame: .zero, lexer: CLexer(), didChangeText: self.onTextChange)
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
  .c: CLexer(),
  .fortran: CLexer(),
  .cpp: CLexer(),
  .cppx: CLexer(),
  .assembly: AssemblyLexer(),
  .cuda: CLexer(),
  .llvm: CLexer(),
  .d: CLexer(),
  .ispc: CLexer(),
  .analysis: CLexer(),
  .go: CLexer(),
  .rust: CLexer(),
  .clean: CLexer(),
  .pascal: CLexer(),
  .haskell: CLexer(),
  .ada: CLexer(),
  .ocaml: CLexer(),
  .swift: SwiftLexer(),
  .zig: CLexer(),
]

private let themeForLanguage: [Language: SyntaxColorTheme] = [
  .c: UniversalTheme<CToken>(),
  .fortran: UniversalTheme<CToken>(),
  .cpp: UniversalTheme<CToken>(),
  .cppx: UniversalTheme<CToken>(),
  .assembly: UniversalTheme<AssemblyToken>(),
  .cuda: UniversalTheme<CToken>(),
  .llvm: UniversalTheme<CToken>(),
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

