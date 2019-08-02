///
///  Document.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import Cocoa
import SwiftUI
import GodBolt

final class Document: NSDocument {
  private var viewModel = ViewModel()
  private var transient: Bool = false
  private let preferences = PreferencesWindowController()

  override class var autosavesInPlace: Bool {
    return true
  }

  override init() {
    super.init()
    self.undoManager?.disableUndoRegistration()
    self.fileType = NSDocumentController.shared.defaultType
    self.undoManager?.enableUndoRegistration()
  }

  func markTransient(_ transient: Bool = true) {
    self.transient = transient
  }

  // Are we transient but also available to be replaced?  If there's a sheet
  // attached, then AppKit is going to lose its mind.
  var isTransientAndReplacable: Bool {
    guard self.transient else {
      return false
    }
    for controller in self.windowControllers {
      if controller.window?.attachedSheet != nil {
        return false
      }
    }
    return true
  }

  override func makeWindowControllers() {
    guard self.windowControllers.count == 0 else {
      return
    }

    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 750),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered, defer: false)
    window.center()

    window.contentView = NSHostingView(rootView: ContentView().environmentObject(self.viewModel))

    let windowController = NSWindowController(window: window)
    self.addWindowController(windowController)
  }

  override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
    guard let data = self.viewModel.documentTextValue.data(using: .utf8) else {
      return FileWrapper()
    }
    return FileWrapper(regularFileWithContents: data)
  }

  override func read(from url: URL, ofType typeName: String) throws {
    self.undoManager?.disableUndoRegistration()
    let data = try Data(contentsOf: url)
    self.viewModel.readData(data, ofType: url.pathExtension)
    self.undoManager?.enableUndoRegistration()
  }

  override func read(from data: Data, ofType typeName: String) throws {
    self.undoManager?.disableUndoRegistration()
    // wewlad
    self.viewModel.readData(data, ofType: typeName)
    self.undoManager?.enableUndoRegistration()
  }

  func read(from string: String, ofType typeName: String, session: SessionContainer.SessionCompiler?) {
     self.undoManager?.disableUndoRegistration()
     // wewlad
     self.viewModel.readString(string, ofType: typeName, session: session)
     self.undoManager?.enableUndoRegistration()
   }

  override func updateChangeCount(_ change: NSDocument.ChangeType) {
    // When a document is changed, it is no longer transient.
    self.transient = false
    super.updateChangeCount(change)
  }

  override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
    super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
    self.viewModel.updateFileExtension(url.pathExtension)
  }
}

extension Document {
  func showPreferences() {
    guard let sheetWindow = self.windowForSheet else {
      return
    }
    sheetWindow.beginSheet(self.preferences.window!) { (response) in

    }
  }
}
