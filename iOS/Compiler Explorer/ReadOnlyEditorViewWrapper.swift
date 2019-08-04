///
///  ReadOnlyEditorViewWrapper.swift
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
import CompilerExplorerKit

final class ReadOnlyEditorViewController: UIViewController {
  let viewModel: ViewModel
  private var compiledTextCancellable: AnyCancellable? = nil

  init(vm: ViewModel) {
    self.viewModel = vm
    super.init(nibName: nil, bundle: nil)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    let syntaxView = SyntaxTextView(frame: .zero, lexer: TokenizingLexer<AssemblyToken>()) { _ in }
    syntaxView.contentTextView.isEditable = false
    syntaxView.theme = UniversalTheme<AssemblyToken>()
    self.compiledTextCancellable = self.viewModel.compiledTextValue.sink { value in
      syntaxView.text = value
    }
    self.view = syntaxView
  }

  deinit {
    self.compiledTextCancellable?.cancel()
  }
}
