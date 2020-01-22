///
///  NativeShareButton.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 8/3/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import AppKit
import SwiftUI
import Combine

struct NativeShareButton: NSViewRepresentable {
  final class Trampoline {
    let shareMenu: NSMenu

    init() {
      self.shareMenu = DocumentController.shared.standardShareMenuItem().submenu!
    }

    @objc func callback(_ sender: AnyObject?) {
      if let event = NSApp?.currentEvent, let sender = sender as? NSView {
        NSMenu.popUpContextMenu(self.shareMenu, with: event, for: sender)
      }
    }
  }

  func makeCoordinator() -> Trampoline {
    return Trampoline()
  }

  init() {
  }

  func makeNSView(context: NSViewRepresentableContext<NativeShareButton>) -> NSButton {
    let button = NSButton(title: "", target: context.coordinator, action: #selector(Trampoline.callback(_:)))
    button.bezelStyle = .rounded
    button.image = NSImage(named: NSImage.shareTemplateName)
    return button
  }

  func updateNSView(_ sourceView: NSButton, context: NSViewRepresentableContext<NativeShareButton>) {

  }
}
