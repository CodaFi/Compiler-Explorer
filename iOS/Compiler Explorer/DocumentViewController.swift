//
//  DocumentViewController.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/27/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import UIKit
import SwiftUI
import GodBolt
import SavannaKit

struct DocumentView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var showSettings = false
  @State var index: Int = 0

  var navigationTitle: String {
    guard let name = self.viewModel.language?.name else {
      return ""
    }
    if self.index == 0 {
      return "\(name) - Input"
    } else {
      return "\(name) - Output"
    }
  }

  var body: some View {
    NavigationView {
      PageViewController(controllers: [
        EditorViewController(text: self.viewModel.documentTextValue, language: self.viewModel.language, onTextChange: self.viewModel.textDidChange),
        ReadOnlyEditorViewController(vm: self.viewModel),
      ], onUpdate: { self.index = $0 })
        .navigationBarTitle(Text(self.navigationTitle), displayMode: .inline)
        .navigationBarItems(leading: Button(action: {
          self.showSettings = true
        }) {
          Image(systemName: "slider.horizontal.3")
          }, trailing: Button(action: {
            self.viewModel.compile()
          }) {
            Image(systemName: "play.fill")
        })
        .sheet(isPresented: self.$showSettings) {
          SettingsView().environmentObject(self.viewModel)
      }
    }
  }
}

#if DEBUG
struct DocumentView_Previews: PreviewProvider {
  static var previews: some View {
    DocumentView()
  }
}
#endif

final class DocumentViewController: UIViewController {
  @ObservedObject var viewModel = ViewModel()
  let document: Document
  var hostingController: UIHostingController<AnyView>?

  init(document: Document) {
    self.viewModel = ViewModel()
    self.document = document
    super.init(nibName: nil, bundle: nil)
    self.viewModel.updateLanguage(self.document.language)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    let view = UIView()
    view.backgroundColor = UIColor.white
    self.hostingController = UIHostingController(rootView: AnyView(DocumentView().environmentObject(self.viewModel)))
    addChild(self.hostingController!)
    view.addSubview(self.hostingController!.view)

    self.hostingController!.view.translatesAutoresizingMaskIntoConstraints = false
    self.hostingController!.view.backgroundColor = UIColor.red
    NSLayoutConstraint.activate([
      self.hostingController!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      self.hostingController!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      self.hostingController!.view.topAnchor.constraint(equalTo: view.topAnchor),
      self.hostingController!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    self.hostingController!.didMove(toParent: self)
    self.view = view
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // Access the document
    document.open(completionHandler: { (success) in
      if success {
        // Display the content of the document, e.g.:
      } else {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
      }
    })
  }

  @IBAction func dismissDocumentViewController() {
    dismiss(animated: true) {
      self.document.close(completionHandler: nil)
    }
  }
}
