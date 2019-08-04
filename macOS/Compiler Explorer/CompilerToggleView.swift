//
//  CompilerToggleView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import Combine
import CompilerExplorerKit

struct CompilerToggleView: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    HStack {
      Picker(selection: self.$viewModel.syntax, label: Text("Syntax")) {
        // Yes, this is absolutely a value judgement.
        Text("Intel").tag(0)
        Text("AT&T").tag(1)
      }
        .padding([ .leading ], 22.0)
        .fixedSize()
      HStack {
        Toggle("Strip Labels", isOn: self.$viewModel.labels)
        Toggle("Strip Directives", isOn: self.$viewModel.directives)
        Toggle("Strip Comments", isOn: self.$viewModel.comments)
        Toggle("Demangle Symbols", isOn: self.$viewModel.demangle)
        Toggle("Trim Whitespace", isOn: self.$viewModel.trim)
      }
      .padding([ .leading, .trailing ], 22.0)
    }
      .disabled(self.$viewModel.availableCompilers.isEmpty)
      .toggleStyle(DefaultToggleStyle())
  }
}

#if DEBUG
struct CompilerToggleView_Preview: PreviewProvider {
  static var previews: some View {
    CompilerToggleView()
  }
}
#endif
