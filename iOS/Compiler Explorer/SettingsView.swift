//
//  SettingsView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 8/1/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    NavigationView {
      Form {
        Section(header: Text("Language")) {
          Text(self.viewModel.language?.name ?? "(none)")
        }
        Section(header: Text("Compiler")) {
          Picker(selection: self.$viewModel.selectedCompiler, label: Text("Compiler")) {
            ForEach(self.viewModel.availableCompilers, id: \.name) { compiler in
              Text(compiler.name).tag(compiler.name)
            }
          }
        }
        Section(header: Text("Compiler Flags")) {
          TextField("Flags", text: self.$viewModel.compilerOptions)
        }
        Section(header: Text("Asssembly Syntax")) {
          Picker(selection: self.$viewModel.syntax, label: Text("Syntax")) {
            // Yes, this is absolutely a value judgement.
            Text("Intel").tag(0)
            Text("AT&T").tag(1)
          }
        }
        Section(header: Text("Options")) {
          Toggle(isOn: self.$viewModel.labels) {
            Text("Strip labels")
          }
          Toggle(isOn: self.$viewModel.directives) {
            Text("Strip directives")
          }
          Toggle(isOn: self.$viewModel.comments) {
            Text("Strip comment-only lines")
          }
          Toggle(isOn: self.$viewModel.demangle) {
            Text("Demangle symbols")
          }
          Toggle(isOn: self.$viewModel.trim) {
            Text("Trim whitespace-only lines")
          }
        }
      }
      .navigationBarTitle("Settings", displayMode: .inline)
      .navigationBarItems(trailing: Button(action: { self.presentationMode.value.dismiss() }, label: { Text("Done") }))
    }
  }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView().environmentObject(ViewModel())
  }
}
#endif
