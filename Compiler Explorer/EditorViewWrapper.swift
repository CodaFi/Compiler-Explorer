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
  let onTextChange: (String) -> Void

  func makeNSView(context: NSViewRepresentableContext<EditorViewWrapper>) -> SyntaxTextView {
    let syntaxView = SyntaxTextView(frame: .zero, lexer: CLexer()) { view in
      self.onTextChange(view.text)
    }
    syntaxView.theme = CTheme()
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
