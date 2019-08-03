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
    let syntaxView = SyntaxTextView(frame: .zero, lexer: CLexer(), didChangeText: self.onTextChange)
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
