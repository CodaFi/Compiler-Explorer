//
//  CompilerSelectorView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import Combine
import GodBolt

struct CompilerSelectorView: View {
  @Binding var compilers: [Compiler]
  @Binding var selectedCompiler: Int
  @Binding var compilerOptions: String

  // wewlad
  @Binding var syntax: Int
  @Binding var labels: Bool
  @Binding var directives: Bool
  @Binding var comments: Bool
  @Binding var demangle: Bool
  @Binding var trim: Bool

  var body: some View {
    VStack {
      HStack {
        Spacer()
        Text("Compiler:")
          .layoutPriority(1.0)
        Picker(selection: self.$selectedCompiler, label: Text("Compiler")) {
          if self.compilers.isEmpty {
            Text("(No Compilers Available)").tag(0)
          } else {
            ForEach(0..<self.compilers.count) {
              Text(self.compilers[$0].name).tag($0)
            }
          }
        }
          .disabled(self.compilers.isEmpty)
          .layoutPriority(1.0)
        Spacer(minLength: 20)
        TextField("Compiler Options...", text: self.$compilerOptions)
          .disabled(self.compilers.isEmpty)
          .layoutPriority(1.0)
        Spacer()
      }
        .frame(height: 64, alignment: .leading)
        .pickerStyle(.popUpButton)

      CompilerToggleView(
        syntax: self.$syntax,
        labels: self.$labels,
        directives: self.$directives,
        comments: self.$comments,
        demangle: self.$demangle,
        trim: self.$trim)
    }
  }
}

#if DEBUG
struct CompilerSelectorView_Preview: PreviewProvider {
  static var compilers: [Compiler] = [
    try! JSONDecoder().decode(Compiler.self, from: JSONEncoder().encode([
      "id": "swift311",
      "name": "x86-64 swiftc 3.1.1",
      "lang": "swift",
    ]))
  ]

  static var previews: some View {
    CompilerSelectorView(
      compilers: .constant(self.compilers),
      selectedCompiler: .constant(0),
      compilerOptions: .constant(""),
      syntax: .constant(0),
      labels: .constant(true),
      directives: .constant(true),
      comments: .constant(true),
      demangle: .constant(true),
      trim: .constant(true))
  }
}
#endif
