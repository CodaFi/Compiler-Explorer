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

#if os(macOS)
public struct EditorViewWrapper: NSViewRepresentable {
  @Binding public var text: String
  @Binding public var language: Language?
  public let onTextChange: (SyntaxTextView) -> Void

  public init(text: Binding<String>, language: Binding<Language?>, onTextChange: @escaping (SyntaxTextView) -> Void) {
    self._text = text
    self._language = language
    self.onTextChange = onTextChange
  }

  public func makeNSView(context: NSViewRepresentableContext<EditorViewWrapper>) -> SyntaxTextView {
    let syntaxView = SyntaxTextView(frame: .zero, lexer: TokenizingLexer<CToken>(), didChangeText: self.onTextChange)
    syntaxView.theme = UniversalTheme<CToken>()
    syntaxView.text = self.text
    return syntaxView
  }

  public func updateNSView(_ sourceView: SyntaxTextView, context: NSViewRepresentableContext<EditorViewWrapper>) {
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
#elseif os(iOS)
public final class EditorViewWrapper: UIViewController {
  public let text: String
  public let language: Language?
  public let onTextChange: (SyntaxTextView) -> Void

  public init(text: String, language: Language?, onTextChange: @escaping (SyntaxTextView) -> Void) {
    self.text = text
    self.language = language
    self.onTextChange = onTextChange
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
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

#else
#error("Unsupported platform")
#endif

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

