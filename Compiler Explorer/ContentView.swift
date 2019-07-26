///
///  ContentView.swift
///
///
///  Created by Robert Widmann on 7/24/19.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import SwiftUI
import SavannaKit
import Combine

struct ContentView: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    VStack {
      CompilerSelectorView(
        compilers: self.$viewModel.availableCompilers,
        selectedCompiler: self.$viewModel.selectedCompiler,
        compilerOptions: self.$viewModel.compilerOptions,
        syntax: self.$viewModel.syntax,
        labels: self.$viewModel.labels,
        directives: self.$viewModel.directives,
        comments: self.$viewModel.comments,
        demangle: self.$viewModel.demangle,
        trim: self.$viewModel.trim)
      // FIXME: Do I really have to force this to work?
      // Even in death, NSSplitView.  Even in death.
      HSplitView {
        EditorViewWrapper(text: self.$viewModel.documentTextValue,
                          language: self.$viewModel.language,
                          onTextChange: self.viewModel.textDidChange)
          .layoutPriority(2.0)
        ReadOnlyEditorViewWrapper(text: self.$viewModel.compiledTextValue)
          .layoutPriority(1.0)
      }
    }
  }
}
