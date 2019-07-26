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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSOpenSavePanelDelegate {
  @IBOutlet weak var documentController: DocumentController!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    NSApp.servicesProvider = self
  }
}

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


extension AppDelegate {
  @IBAction func showPreferences(_ sender: AnyObject?) {
    // Forward on to the top of the document stack.
    guard let doc = self.documentController.currentDocument else {
      return
    }
    (doc as! Document).showPreferences()
  }
}

// FIXME: Beta bugs mean that this cannot be in Preferences.swift where it
// belongs without my Xcode barfing.
//
// We'll get em' next time.
final class PreferencesWindowController: NSWindowController {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(window: NSWindow?) {
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 800),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered, defer: false)
    window.center()

    window.contentView = NSHostingView(rootView: PreferencesView(onDismiss: {
      window.sheetParent!.endSheet(window)
    }))
    super.init(window: window)
    self.window = window
  }
}
