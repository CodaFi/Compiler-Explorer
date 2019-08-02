//
//  ResponsiveTextView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/28/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI

struct ResponsiveTextField: UIViewRepresentable {
  final class Coordinator: NSObject, UITextFieldDelegate {

    @Binding var text: String
    var didBecomeFirstResponder = false

    init(text: Binding<String>) {
      self._text = text
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
      self.text = textField.text ?? ""
    }

  }

  @Binding var text: String
  var placeholder: String
  var isFirstResponder: Bool = false

  func makeUIView(context: UIViewRepresentableContext<ResponsiveTextField>) -> UITextField {
    let textField = UITextField(frame: .zero)
    textField.delegate = context.coordinator
    textField.autocorrectionType = .no
    textField.allowsEditingTextAttributes = false
    textField.placeholder = self.placeholder
    return textField
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(text: self.$text)
  }

  func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<ResponsiveTextField>) {
    uiView.text = text
    if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
      uiView.becomeFirstResponder()
      context.coordinator.didBecomeFirstResponder = true
    }
  }
}
