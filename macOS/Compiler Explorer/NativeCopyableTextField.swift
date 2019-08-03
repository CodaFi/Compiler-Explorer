//
//  NativeCopyableTextField.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 8/3/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import AppKit
import SwiftUI
import Combine

struct NativeCopyableTextField: NSViewRepresentable {
  @Binding var string: String
  let placeholder: String

  @objc final class Coordinator: NSObject, NSTextFieldDelegate {

  }

  func makeCoordinator() -> Coordinator {
    return Coordinator()
  }

  var stringValue: String {
    return self.string.isEmpty ? self.placeholder : self.string
  }

  func makeNSView(context: NSViewRepresentableContext<NativeCopyableTextField>) -> NSTextField {
    let field = NSTextField(string: self.stringValue)
    field.isEditable = false
    field.isSelectable = true
    field.delegate = context.coordinator
    return field
  }

  func updateNSView(_ nsView: NSTextField, context: NSViewRepresentableContext<NativeCopyableTextField>) {
    nsView.selectText(nil)
    nsView.stringValue = self.stringValue
  }
}
