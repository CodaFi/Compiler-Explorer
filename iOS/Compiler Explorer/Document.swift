//
//  Document.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/27/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import UIKit
import GodBolt

class Document: UIDocument {
  override func contents(forType typeName: String) throws -> Any {
      // Encode your document with an instance of NSData or NSFileWrapper
      return Data()
  }

  override func load(fromContents contents: Any, ofType typeName: String?) throws {
      // Load your document from contents
  }
}

