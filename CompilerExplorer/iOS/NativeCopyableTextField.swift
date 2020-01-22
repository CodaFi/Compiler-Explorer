//
//  NativeCopyableTextField.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 8/3/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI

struct NativeCopyableTextField: UIViewRepresentable {
  @Binding var string: String
  let placeholder: String

  @objc final class Coordinator: NSObject, UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      return false
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator()
  }

  var stringValue: String {
    return self.string.isEmpty ? self.placeholder : self.string
  }

  func makeUIView(context: UIViewRepresentableContext<NativeCopyableTextField>) -> UITextField {
    let field = UITextField()
    field.text = self.stringValue
    field.inputView = UIView()
    field.delegate = context.coordinator
    return field
  }

  func updateUIView(_ view: UITextField, context: UIViewRepresentableContext<NativeCopyableTextField>) {
    view.text = self.stringValue
  }
}
