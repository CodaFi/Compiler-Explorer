///
///  AppDelegate.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import Cocoa
import SwiftUI
import Combine
import GodBolt
import Logging

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate, NSOpenSavePanelDelegate {

  private let client = Client()

  override init() {
    LoggingSystem.bootstrap(StreamLogHandler.standardOutput)
    UserDefaults.standard.register(defaults: [
      "PreviousShortlinks": [String]()
    ])
    gotoShortlinksController = GotoShortlinkWindowController(client: client)
  }

  @IBOutlet weak var documentController: DocumentController!
  let gotoShortlinksController: GotoShortlinkWindowController
  var shortlinkCancellable: AnyCancellable? = nil

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApp.servicesProvider = self
  }
}

// MARK: System Services

extension AppDelegate {
  @objc func openFile(_ pasteboard: NSPasteboard, userData data: NSString, error: UnsafeMutablePointer<NSString>) {
    guard
      let type = pasteboard.availableType(from: [ .init(kUTTypePlainText as String) ]),
      let filename = pasteboard.string(forType: type)
    else {
      return
    }

    guard (filename as NSString).isAbsolutePath else {
      return
    }

    let url = URL(fileURLWithPath: filename)
    self.documentController.openDocument(withContentsOf: url, display: true) { _, _, err in
      guard err != nil else {
        return
      }
      _ = NSAlert(error: NSError(domain: NSCocoaErrorDomain, code: NSFileReadInvalidFileNameError, userInfo: [
        NSFilePathErrorKey: filename
      ])).runModal()
    }
  }

  // FIXME: Do we really want to implement these global services?
  @objc func openSelection(_ pasteboard: NSPasteboard, userData data: NSString, error: UnsafeMutablePointer<NSString>) {
    fatalError()
//    self.documentController.openDocument(withContentsOf: url, display: true) { _, _, err in
//      guard let err = err else {
//        return
//      }
//      _ = NSAlert(error: NSError(domain: NSCocoaErrorDomain, code: NSFileReadInvalidFileNameError, userInfo: [
//        NSFilePathErrorKey: filename
//      ]))
//    }
  }
}

// MARK: Menu Actions

extension AppDelegate {
  @IBAction func showPreferences(_ sender: AnyObject?) {
    // Forward on to the top of the document stack.
    guard let doc = self.documentController.currentDocument else {
      return
    }
    (doc as! Document).showPreferences()
  }

  @IBAction func openShortlink(_ sender: AnyObject?) {
    self.shortlinkCancellable?.cancel()
    self.shortlinkCancellable = self.gotoShortlinksController.viewModel.shortlinkValue
      .compactMap({ $0 })
      .receive(on: DispatchQueue.main)
      .sink { session in
      for session in session.sessions {
        self.documentController.openDocument(
          pasteboard: session.source,
          type: session.language,
          session: session.compilers.first)
      }
    }
    _ = NSApp.runModal(for: self.gotoShortlinksController.window!)
  }

  @IBAction func generateShortlink(_ sender: AnyObject?) {
    guard let doc = self.documentController.currentDocument else {
      return
    }
    (doc as! Document).generateShortlink()
  }
}

// MARK: NSMenuValidation

extension AppDelegate {
  @objc func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
    guard menuItem.action == #selector(AppDelegate.generateShortlink(_:)) else {
      return true
    }

    guard let topDoc = self.documentController.currentDocument else {
      return false
    }
    guard let doc = topDoc as? Document else {
      return false
    }
    return !doc.isTransientAndReplacable && doc.viewModel.language != nil
  }
}
