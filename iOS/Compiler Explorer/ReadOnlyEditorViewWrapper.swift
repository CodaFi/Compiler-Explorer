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

final class ReadOnlyEditorViewController: UIViewController {
  let viewModel: ViewModel

  init(vm: ViewModel) {
    self.viewModel = vm
    super.init(nibName: nil, bundle: nil)

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    let syntaxView = SyntaxTextView(frame: .zero, lexer: AssemblyLexer()) { _ in }
    syntaxView.contentTextView.isEditable = false
    syntaxView.theme = AssemblyTheme()
    self.viewModel.registerCompileCallback { value in
      syntaxView.text = value
    }
    self.view = syntaxView
  }
}
