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
  var viewModel: ViewModel
  @State var showSettings = false
  @State var index: Int = 0
  var controllers: [UIViewController] = []
  @Environment(\.presentationMode) var presentationMode
  let onDismiss: () -> Void

  init(viewModel: ViewModel, onDismiss: @escaping () -> Void) {
    self.viewModel = viewModel
    self.onDismiss = onDismiss

    self.controllers = [
      EditorViewController(text: self.viewModel.documentTextValue.value,
                           language: self.viewModel.language,
                           onTextChange: self.viewModel.textDidChange),
      ReadOnlyEditorViewController(vm: self.viewModel),
    ]
  }

  var navigationTitle: String {
    guard let name = self.viewModel.language?.name else {
      return ""
    }

    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      guard !self.viewModel.availableCompilers.isEmpty else {
        return name
      }
      return "\(name) - \(self.viewModel.availableCompilers[self.viewModel.selectedCompiler].name)"
    case .phone:
      if self.index == 0 {
        return "\(name) - Input"
      } else {
        return "\(name) - Output"
      }
    default:
      fatalError()
    }
  }

  var body: some View {
    NavigationView {
      ZStack(alignment: .bottom) {
        PageViewController(controllers: self.controllers, currentPage: self.$index)
        if UIDevice.current.userInterfaceIdiom == .phone {
          PageControl(numberOfPages: self.controllers.count, currentPage: self.$index)
            .padding(.bottom, 40)
        }
      }
      .navigationBarTitle(Text(self.navigationTitle), displayMode: .inline)
      .navigationBarItems(leading: Button(action: {
        self.showSettings = true
      }) {
        Image(systemName: "slider.horizontal.3")
          .frame(width: 40, height: 40)
        }, trailing: Button(action: {
          self.onDismiss()
        }) { Text("Done") })
        .sheet(isPresented: self.$showSettings) {
          SettingsView().environmentObject(self.viewModel)
        }
    }
      .navigationViewStyle(StackNavigationViewStyle())
      .edgesIgnoringSafeArea([ .bottom, .leading, .trailing ])
  }
}

#if DEBUG
struct DocumentView_Previews: PreviewProvider {
  static var previews: some View {
    DocumentView(viewModel: ViewModel(), onDismiss: {})
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
    self.viewModel.updateLanguage(from: self.document.fileURL)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func loadSession(_ session: SessionContainer.Session, compiler: SessionContainer.SessionCompiler) {
    self.viewModel.loadSession(session, compiler: compiler)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.hostingController = UIHostingController(rootView: AnyView(DocumentView(viewModel: self.viewModel) { self.dismissDocumentViewController() }))
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

  

  func dismissDocumentViewController() {
    dismiss(animated: true) {
      self.document.close(completionHandler: nil)
    }
  }
}
