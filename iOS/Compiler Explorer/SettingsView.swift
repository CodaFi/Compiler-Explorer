//
//  SettingsView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 8/1/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import CompilerExplorerKit

struct SettingsView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

  private var languageSection: some View {
    Section(header: Text("Language")) {
      Text(self.viewModel.language?.name ?? "(none)")
    }
  }

  private var compilerSection: some View {
    Section(header: Text("Compiler")) {
      Picker(selection: self.$viewModel.selectedCompiler, label: Text("Compiler")) {
        ForEach(0..<self.viewModel.availableCompilers.count) { idx in
          Text(self.viewModel.availableCompilers[idx].name).tag(idx)
        }
      }
    }
  }

  private var compilerFlagsSection: some View {
    Section(header: Text("Compiler Flags")) {
      TextField("Flags", text: self.$viewModel.compilerOptions)
    }
  }

  private var shortLinkSection: some View {
    Section(header: Text("Shortlink")) {
      if self.viewModel.shortlinkValue.isEmpty {
        AnyView(Button(action: { self.viewModel.computeShortlinkForBuffer() }) { Text("Compute Shortlink...") })
      } else {
        AnyView(NativeCopyableTextField(string: self.$viewModel.shortlinkValue, placeholder: "Loading..."))
      }
    }
  }

  private var assemblySyntaxSection: some View {
    Section(header: Text("Asssembly Syntax")) {
      Picker(selection: self.$viewModel.syntax, label: Text("Syntax")) {
        // Yes, this is absolutely a value judgement.
        Text("Intel").tag(0)
        Text("AT&T").tag(1)
      }
    }
  }

  private var optionsSection: some View {
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

  var body: some View {
    NavigationView {
      Form {
        languageSection
        compilerSection
        compilerFlagsSection
        shortLinkSection
        assemblySyntaxSection
        optionsSection
      }
      .navigationBarTitle("Settings", displayMode: .inline)
      .navigationBarItems(trailing: Button(action: { self.presentationMode.wrappedValue.dismiss() }, label: { Text("Done") }))
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
