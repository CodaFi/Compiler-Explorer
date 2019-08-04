///
///  DocumentController.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/25/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import AppKit
import GodBolt

final class DocumentController: NSDocumentController {
  // Because we're creating our own window, AppKit relinquishes responsibility
  // for placing them on the screen in an attractive way.  Luckily, AppKit also
  // provides a convenient method for updating the "cascade point" of
  // the windows an application creates.  We just have to keep track of the
  // last cascade point, and make sure that all window creation routes through
  // us.
  private var cascadePoint: NSPoint = .zero
}

// MARK: NSDocumentController's Religious Rites

extension DocumentController {
  override func addDocument(_ document: NSDocument) {
    guard self.documents.count == 1 else {
      return super.addDocument(document)
    }
    (self.documents[0] as! Document).markTransient(false)
    return super.addDocument(document)
  }

  override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
    let doc = try super.openUntitledDocumentAndDisplay(false) as! Document
    doc.makeWindowControllers()
    self.cascadePoint = doc.showWindows(at: self.cascadePoint)
    guard self.documents.count == 1 else {
      return doc
    }

    guard let eventDesc = NSAppleEventManager.shared().currentAppleEvent else {
      return doc
    }

    let eventID = eventDesc.eventID
    guard eventID == kAEReopenApplication || eventID == kAEOpenApplication else {
      return doc
    }

    guard eventDesc.eventClass == kCoreEventClass else {
      return doc
    }

    doc.markTransient()
    return doc
  }

  func openDocument(pasteboard: String, type: String, session: SessionContainer.SessionCompiler?) {
    if let doc = self.transientDocumentToReplace() {
      doc.markTransient(false)
      doc.read(from: pasteboard, ofType: type, session: session)
      doc.updateChangeCount(.changeReadOtherContents)
      self.cascadePoint = doc.showWindows(at: self.cascadePoint)
    } else {
      let doc = Document()
      doc.read(from: pasteboard, ofType: type, session: session)
      doc.updateChangeCount(.changeReadOtherContents)
      self.addDocument(doc)
      doc.makeWindowControllers()
      self.cascadePoint = doc.showWindows(at: self.cascadePoint)
    }
  }
  
  override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
    let transientDoc = self.transientDocumentToReplace()
    if let transientDoc = transientDoc {
      transientDoc.markTransient(false)
    }
    super.openDocument(withContentsOf: url, display: false) { doc, val, err in
      guard let doc = doc as? Document else {
        fatalError("Invalid document created?")
      }

      if let transientDoc = transientDoc {
        try! doc.read(from: url, ofType: url.pathExtension)
        transientDoc.close()
      }
      if displayDocument {
        doc.makeWindowControllers()
        self.cascadePoint = doc.showWindows(at: self.cascadePoint)
      }
      completionHandler(doc, val, err)
    }
  }

  // The first document that is created by default is created empty, nameless,
  // and formless.  We call this document "transient" because the user can
  // perform one of three further actions:
  //
  // 1) Save the current document
  // 2) Open another document
  // 3) Create another document
  //
  // In the first case, we're all good because the document is now really
  // committed somewhere and we can thus knock off the transient bit.  In the
  // second case, the transient document really wasn't important anyways
  // so we'll just handle the responsiblity of closing it as we open the
  // other document. In the third case, the user clearly has some purpose
  // in mind for both documents.  We will not replace either one.
  //
  // This notion of "transient document" mirrors the one from TextEdit.app.
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
}

// MARK: Open Panel Customization

extension DocumentController: NSOpenSavePanelDelegate {
  override func beginOpenPanel(_ panel: NSOpenPanel, forTypes inTypes: [String]?, completionHandler: @escaping (Int) -> Void) {
    panel.allowsOtherFileTypes = false
    panel.allowsMultipleSelection = true
    panel.allowedFileTypes = ExtensionManager.allExtensions
    panel.delegate = self
    super.beginOpenPanel(panel, forTypes: nil, completionHandler: completionHandler)
  }
}
