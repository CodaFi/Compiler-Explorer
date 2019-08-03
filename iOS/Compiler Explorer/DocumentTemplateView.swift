//
//  DocumentTemplateView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/28/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import GodBolt

struct DocumentTemplateView: View {
  @Binding var chosen: Language?
  @State var selection: Int? = nil
  @EnvironmentObject var shortlinkModel: ShortlinkViewModel


  private func viewForValue(_ value: Int) -> some View {
    if value != 0 {
      return AnyView(Button(action: { self.chosen = availableLanguages[value-1] }) {
        HStack {
          Text(availableLanguages[value-1]!.name)
          Spacer()
          Image(systemName: "chevron.right")
        }
      })
    } else {
      return AnyView(NavigationLink("Go To Link...", destination: ShortlinkPanelView().environmentObject(self.shortlinkModel)))
    }
  }

  var body: some View {
    NavigationView {
      List(0..<availableLanguages.count+1) { value in
        self.viewForValue(value)
      }
        .navigationBarTitle("New Workspace")
    }
  }
}


private let availableLanguages: [Language?] = [
  .c,
  .fortran,
  .cpp,
  .cppx,
  .assembly,
  .cuda,
  .llvm,
  .d,
  .ispc,
  .analysis,
  .go,
  .rust,
  .clean,
  .pascal,
  .haskell,
  .ada,
  .ocaml,
  .swift,
  .zig,
]

#if DEBUG
struct DocumentTemplateView_Previews: PreviewProvider {
  static var previews: some View {
    DocumentTemplateView(chosen: .constant(nil))
  }
}

#endif
