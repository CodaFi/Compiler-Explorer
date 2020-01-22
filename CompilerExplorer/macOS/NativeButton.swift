///
///  NativeButton.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/26/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import SwiftUI
import Combine

struct NativeButton: NSViewRepresentable {
  final class Trampoline {
    let action: () -> Void

    init(_ action: @escaping () -> Void) {
      self.action = action
    }

    @objc func callback(_ sender: AnyObject?) {
      self.action()
    }
  }
  let title: String
  let keyEquivalent: String
  let action: () -> Void

  func makeCoordinator() -> Trampoline {
    return Trampoline(self.action)
  }

  init(title: String, keyEquivalent: String, action: @escaping () -> Void) {
    self.title = title
    self.keyEquivalent = keyEquivalent
    self.action = action
  }

  func makeNSView(context: NSViewRepresentableContext<NativeButton>) -> NSButton {
    let button = NSButton(title: title, target: context.coordinator, action: #selector(Trampoline.callback(_:)))
    button.keyEquivalent = self.keyEquivalent
    button.bezelStyle = .rounded
    return button
  }

  func updateNSView(_ sourceView: NSButton, context: NSViewRepresentableContext<NativeButton>) {

  }
}

#if DEBUG
struct NativeButton_Preview: PreviewProvider {
  static var previews: some View {
    NativeButton(title: "", keyEquivalent: "", action: {})
  }
}
#endif
