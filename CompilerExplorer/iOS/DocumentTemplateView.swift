//
//  DocumentTemplateView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/28/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import Combine
import SwiftUI
import GodBolt
import CompilerExplorerKit
import Logging

struct DocumentTemplateView: View {
  @Binding var chosen: Language?
  @State var selection: Int? = nil
  @EnvironmentObject var shortlinkModel: GotoShortlinkViewModel

  @ObservedObject var viewModel: DocumentTemplateViewModel

  var body: some View {
    NavigationView {
      Form {
        Section {
          NavigationLink("Go To Link...", destination: GotoShortlinkView())
        }
        Section {
          if viewModel.languages.isEmpty {
            SpinnerView(isAnimating: .constant(true))
          } else {
            ForEach(viewModel.languages) { language in
              Button(action: { self.chosen = language }) {
                HStack {
                  Text(language.name)
                  Spacer()
                  Image(systemName: "chevron.right")
                }
              }
            }
          }
        }
      }.onAppear(perform: viewModel.loadLanguages)
      .navigationBarTitle("New Workspace")
    }
  }
}

#if DEBUG
struct DocumentTemplateView_Previews: PreviewProvider {
  static var previews: some View {
    DocumentTemplateView(chosen: .constant(nil), viewModel: .init(client: TestClient()))
  }
}

#endif

final class DocumentTemplateViewModel: ObservableObject {

  @Published private(set) var languages = [Language]()

  private var languagesCancellable: AnyCancellable?

  private let logger = Logger(label: "com.codafi.CompilerExplorer.DocumentTemplateViewModel")

  let client: ClientProtocol

  init(client: ClientProtocol) {
    self.client = client
  }

  func loadLanguages() {
    languagesCancellable = client.requestLanguages()
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          if case let .failure(error) = completion {
            // FIXME: Handle the error
            self?.logger.error("\(error)")
          }
        },
        receiveValue: { [weak self] languages in
          self?.languages = languages
        }
      )
  }
}
