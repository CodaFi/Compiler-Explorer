//
//  DocumentController.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/25/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import AppKit
import GodBolt

final class DocumentController: NSDocumentController {
  override func addDocument(_ document: NSDocument) {
    guard self.documents.count == 1 else {
      return super.addDocument(document)
    }
    (self.documents[0] as! Document).markTransient(false)
    return super.addDocument(document)
  }

  override func beginOpenPanel(_ panel: NSOpenPanel, forTypes inTypes: [String]?, completionHandler: @escaping (Int) -> Void) {
    panel.allowsOtherFileTypes = false
    panel.allowsMultipleSelection = true
    panel.allowedFileTypes = ExtensionManager.allExtensions
    panel.delegate = self
    super.beginOpenPanel(panel, forTypes: nil, completionHandler: completionHandler)
  }

  override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
    let doc = try super.openUntitledDocumentAndDisplay(displayDocument) as! Document
    guard self.documents.count == 1 else {
      return doc
    }

    guard let eventDesc = NSAppleEventManager.shared().currentAppleEvent else {
      return doc
    }

    let eventID = eventDesc.eventID
    guard (eventID == kAEReopenApplication || eventID == kAEOpenApplication) else {
      return doc
    }

    guard eventDesc.eventClass == kCoreEventClass else {
      return doc
    }

    doc.markTransient()
    return doc
  }

  private func transientDocumentToReplace() -> Document? {
    guard self.documents.count == 1 else {
      return nil
    }

    let doc = self.documents[0] as! Document
    guard doc.isTransientAndReplacable else {
      return nil
    }
    return doc
  }

  func openDocument(pasteboard: String, type: String, session: SessionContainer.SessionCompiler?) {
    if let doc = self.transientDocumentToReplace() {
      doc.markTransient(false)
      doc.read(from: pasteboard, ofType: type, session: session)
      doc.updateChangeCount(.changeReadOtherContents)
      doc.showWindows()
    } else {
      let doc = Document()
      doc.read(from: pasteboard, ofType: type, session: session)
      doc.updateChangeCount(.changeReadOtherContents)
      self.addDocument(doc)
      doc.makeWindowControllers()
      doc.showWindows()
    }
  }
  
  override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
    let transientDoc = self.transientDocumentToReplace()
    if let transientDoc = transientDoc {
      transientDoc.markTransient(false)
    }
    super.openDocument(withContentsOf: url, display: displayDocument) { doc, val, err in
      if let transientDoc = transientDoc, let doc = doc {
        try! doc.read(from: url, ofType: url.pathExtension)
        if displayDocument {
          doc.makeWindowControllers()
          doc.showWindows()
        }
        transientDoc.close()
      }
      completionHandler(doc, val, err)
    }
  }
}

extension DocumentController: NSOpenSavePanelDelegate {

}
