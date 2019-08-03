///
///  EditorViewWrapper.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import SwiftUI
import Combine
import SavannaKit
import GodBolt

struct EditorViewWrapper: NSViewRepresentable {
  @Binding var text: String
  @Binding var language: Language?
  let onTextChange: (SyntaxTextView) -> Void

  func makeNSView(context: NSViewRepresentableContext<EditorViewWrapper>) -> SyntaxTextView {
    let syntaxView = SyntaxTextView(frame: .zero, lexer: TokenizingLexer<CToken>(), didChangeText: self.onTextChange)
    syntaxView.theme = UniversalTheme<CToken>()
    syntaxView.text = self.text
    return syntaxView
  }

  func updateNSView(_ sourceView: SyntaxTextView, context: NSViewRepresentableContext<EditorViewWrapper>) {
    guard let language = self.language else {
      return
    }
    guard
      let lexer = lexerForLanguage[language],
      let theme = themeForLanguage[language]
    else {
      return
    }
    guard sourceView.lexer !== lexer else {
      return
    }
    sourceView.theme = theme
    sourceView.lexer = lexer
  }
}

private let lexerForLanguage: [Language: Lexer] = [
  .c: TokenizingLexer<CToken>(),
  .fortran: TokenizingLexer<CToken>(),
  .cpp: TokenizingLexer<CppToken>(),
  .cppx: TokenizingLexer<CppToken>(),
  .assembly: TokenizingLexer<AssemblyToken>(),
  .cuda: TokenizingLexer<CToken>(),
  .llvm: TokenizingLexer<LLVMToken>(),
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


#if DEBUG
struct EditorViewWrapper_Preview: PreviewProvider {
  static var sampleText: String = """
    func foo() {}
  """

  static var previews: some View {
    EditorViewWrapper(
      text: .constant(self.sampleText),
      language: .constant(.c),
      onTextChange: { _ in })
  }
}
#endif
