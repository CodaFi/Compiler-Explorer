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
  .c: CTheme(),
  .fortran: CTheme(),
  .cpp: CTheme(),
  .cppx: CTheme(),
  .assembly: AssemblyTheme(),
  .cuda: CTheme(),
  .llvm: CTheme(),
  .d: CTheme(),
  .ispc: CTheme(),
  .analysis: CTheme(),
  .go: CTheme(),
  .rust: CTheme(),
  .clean: CTheme(),
  .pascal: CTheme(),
  .haskell: CTheme(),
  .ada: CTheme(),
  .ocaml: CTheme(),
  .swift: SwiftTheme(),
  .zig: CTheme(),
]

