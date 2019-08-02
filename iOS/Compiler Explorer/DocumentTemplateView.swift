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

  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    NavigationView {
      List(availableLanguages) { value in
        Button(action: { self.chosen = value }) {
         HStack {
            Text(value.name)
            Spacer()
            Image(systemName: "chevron.right")
          }
        }
      }
        .navigationBarTitle("New Workspace")
    }
  }
}


private let availableLanguages: [Language] = [
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
