///
///  CompilerSelectorView.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import SwiftUI
import Combine
import GodBolt
import CompilerExplorerKit

struct CompilerSelectorView: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    VStack {
      HStack {
        Spacer()
        Picker(selection: self.$viewModel.selectedCompiler, label: Text("Compiler")) {
          if self.viewModel.availableCompilers.isEmpty {
            Text("(No Compilers Available)").tag(0)
          } else {
            ForEach(0..<self.viewModel.availableCompilers.count) {
              Text(self.viewModel.availableCompilers[$0].name).tag($0)
            }
          }
        }
          .fixedSize()
          .layoutPriority(1.0)
        Spacer(minLength: 20)
        TextField("Compiler Options...", text: self.$viewModel.compilerOptions)
          .layoutPriority(1.0)
        if !self.viewModel.liveCompile {
          Button("Go!", action: self.viewModel.recompile)
            .frame(width: 50)
        }
        Spacer()
      }
      .padding(.top, 10)
        .frame(height: 44, alignment: .leading)
        .pickerStyle(PopUpButtonPickerStyle())
      Divider()
      CompilerToggleView()
        .padding(.top, 2)
    }
    .disabled(self.viewModel.availableCompilers.isEmpty)
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
    CompilerSelectorView()
  }
}
#endif
