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
import CompilerExplorerKit

final class Document: NSDocument {
  let viewModel: ViewModel
  private var transient: Bool = false
  private let preferences: PreferencesWindowController
  let shortlinksController: ShortlinkWindowController

  override class var autosavesInPlace: Bool {
    return true
  }

  override init() {
    self.viewModel = ViewModel(client: Client())
    self.preferences = PreferencesWindowController(viewModel: self.viewModel)
    self.shortlinksController = ShortlinkWindowController(viewModel: self.viewModel)
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

  @available(*, deprecated, message: "Use the cascade-point-aware API instead")
  override func showWindows() {
    fatalError("Cannot show windows!  Use the cascade-point-aware API instead")
  }
  
  func showWindows(at cascadePoint: NSPoint) -> NSPoint {
    guard let controller = self.windowControllers.first else {
      fatalError("Must call makeWindowControllers() first")
    }

    guard let window = controller.window else {
      fatalError("Must call makeWindowControllers() first")
    }


    var point = window.cascadeTopLeft(from: cascadePoint)
    // If the cascade point is zero, we're trying to display the first window.
    // Cascading again will give us a great starting point.
    if cascadePoint == .zero {
      point = window.cascadeTopLeft(from: point)
    }
    self.windowControllers[0].window?.setFrameTopLeftPoint(point)
    super.showWindows()
    return point
  }

  override func makeWindowControllers() {
    guard self.windowControllers.count == 0 else {
      return
    }

    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered, defer: false)
    window.contentView = NSHostingView(rootView: ContentView().environmentObject(self.viewModel))

    let windowController = NSWindowController(window: window)
    self.addWindowController(windowController)
  }

  override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
    guard let data = self.viewModel.documentTextValue.value.data(using: .utf8) else {
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
    self.viewModel.updateLanguage(from: url)
  }

  override func share(with sharingService: NSSharingService, completionHandler: ((Bool) -> Void)? = nil) {
    sharingService.perform(withItems: [ self.viewModel.shortlinkValue ])
  }
}

extension Document {
  func showPreferences() {
    guard let sheetWindow = self.windowForSheet else {
      return
    }
    sheetWindow.beginSheet(self.preferences.window!) { response in }
  }

  func generateShortlink() {
    guard let sheetWindow = self.windowForSheet else {
      return
    }
    self.viewModel.computeShortlinkForBuffer()
    sheetWindow.beginSheet(self.shortlinksController.window!) { response in }
  }
}
