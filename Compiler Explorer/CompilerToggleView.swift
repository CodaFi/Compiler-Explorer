//
//  CompilerToggleView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import Combine

struct CompilerToggleView: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    HStack {
      Spacer()
      Picker(selection: self.$viewModel.syntax, label: Text("Syntax")) {
        // Yes, this is absolutely a value judgement.
        Text("Intel").tag(0)
        Text("AT&T").tag(1)
      }
        .layoutPriority(1.0)
      Spacer(minLength: 22.0)
      Toggle("Strip Labels", isOn: self.$viewModel.labels)
        .layoutPriority(1.0)
      Toggle("Strip Directives", isOn: self.$viewModel.directives)
        .layoutPriority(1.0)
      Toggle("Strip Comments", isOn: self.$viewModel.comments)
        .layoutPriority(1.0)
      Toggle("Demangle Symbols", isOn: self.$viewModel.demangle)
        .layoutPriority(1.0)
      Toggle("Trim Whitespace", isOn: self.$viewModel.trim)
        .layoutPriority(1.0)
      Spacer()
    }
      .toggleStyle(.default)
  }
}

#if DEBUG
struct CompilerToggleView_Preview: PreviewProvider {
  static var previews: some View {
    CompilerToggleView()
  }
}
#endif
