//
//  DocumentBrowserViewController.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/27/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import GodBolt

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate, ObservableObject, Identifiable {
  var languageCancellable: AnyCancellable? = nil
  @Published var selectedLanguage: Language? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    self.delegate = self

    self.allowsDocumentCreation = true
    self.allowsPickingMultipleItems = false
  }


  // MARK: UIDocumentBrowserViewControllerDelegate

	func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {

    let controller = UIHostingController(rootView: DocumentTemplateView(chosen: self[\.selectedLanguage]).environmentObject(GotoShortlinkViewModel()))
    self.languageCancellable = self.$selectedLanguage.sink { value in
      guard let value = value else {
        return importHandler(nil, .none)
      }
      self.dismisssForLanguageChange(language: value, importHandler: importHandler)
    }
    controller.modalPresentationStyle = .popover
    controller.popoverPresentationController?.sourceView = self.view
    self.present(controller, animated: true, completion: nil)
	}

  private func resetLanguageState() {
    self.presentedViewController?.dismiss(animated: true)
    self.languageCancellable?.cancel()
    self.languageCancellable = nil
    self.selectedLanguage = nil
  }

  func dismisssForLanguageChange(language: Language, importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
    self.resetLanguageState()

    let newName = "temp.\(ExtensionManager.fileExtension(for: language))"

    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(newName)
    let doc = Document(fileURL: url)
    doc.save(to: url, for: .forCreating) { (_) in
      doc.close(completionHandler: { (_) in
        importHandler(url, .move)
      })
    }
    presentDocument(at: url, language: language)
  }

  func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
    guard let sourceURL = documentURLs.first else { return }

    // Present the Document View Controller for the first document that was picked.
    // If you support picking multiple items, make sure you handle them all.
    presentDocument(at: sourceURL, language: .c)
  }

  func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
    // Present the Document View Controller for the new newly created document
    presentDocument(at: destinationURL, language: .c)
  }

  func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
    // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
  }

  // MARK: Document Presentation

  func presentDocument(at documentURL: URL, language: Language) {
    let documentViewController = DocumentViewController(document: Document(fileURL: documentURL))
    switch UIDevice.current.userInterfaceIdiom {
    case .pad:
      documentViewController.modalPresentationStyle = .fullScreen
    case .phone:
      documentViewController.modalPresentationStyle = .automatic
    default:
      fatalError()
    }
    present(documentViewController, animated: true, completion: nil)
  }
}

