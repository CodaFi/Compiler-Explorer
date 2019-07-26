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
  // wewlad
  @Binding var syntax: Int
  @Binding var labels: Bool
  @Binding var directives: Bool
  @Binding var comments: Bool
  @Binding var demangle: Bool
  @Binding var trim: Bool

  var body: some View {
    HStack {
      Spacer()
      Picker(selection: self.$syntax, label: Text("Syntax")) {
        // Yes, this is absolutely a value judgement.
        Text("Intel").tag(0)
        Text("AT&T").tag(1)
      }
        .layoutPriority(1.0)
      Spacer(minLength: 22.0)
      Toggle("Strip Labels", isOn: self.$labels)
        .layoutPriority(1.0)
      Toggle("Strip Directives", isOn: self.$directives)
        .layoutPriority(1.0)
      Toggle("Strip Comments", isOn: self.$comments)
        .layoutPriority(1.0)
      Toggle("Demangle Symbols", isOn: self.$demangle)
        .layoutPriority(1.0)
      Toggle("Trim Whitespace", isOn: self.$trim)
        .layoutPriority(1.0)
      Spacer()
    }
      .toggleStyle(.default)
  }
}

#if DEBUG
struct CompilerToggleView_Preview: PreviewProvider {
  static var previews: some View {
    CompilerToggleView(syntax: .constant(0),
                       labels: .constant(true),
                       directives: .constant(true),
                       comments: .constant(true),
                       demangle: .constant(true),
                       trim: .constant(true))
  }
}
#endif
