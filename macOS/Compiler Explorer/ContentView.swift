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
import CompilerExplorerKit

struct ContentView: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    VStack {
      CompilerSelectorView()
      // FIXME: Do I really have to force this to work?
      // Even in death, NSSplitView.  Even in death.
      HSplitView {
        EditorViewWrapper(text: self.$viewModel.documentTextValue[\.value],
                          language: self.$viewModel.language,
                          onTextChange: self.viewModel.textDidChange)
          .frame(minWidth: 400, idealWidth: 400, maxWidth: .infinity)
        ReadOnlyEditorViewWrapper(text: self.$viewModel.compiledTextValue[\.value])
          .frame(minWidth: 400, idealWidth: 400, maxWidth: .infinity)
      }
    }
  }
}
