///
///  Preferences.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/25/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import AppKit
import SwiftUI
import Combine

struct PreferencesView: View {
  @State private var isLive: Bool = true
  let onDismiss: () -> Void

  // FIXME: Open Questions:
  // - Why can't I make a default button in SwiftUI?
  // - Right-align the done button?
  // - This definitely shouldn't be a sheet?
  //
  // Oh well, it isn't hooked up to anything yet.
  var body: some View {
    VStack {
      GroupBox(label: Text("Preferences")) {
        Toggle("Live Compilation", isOn: self.$isLive)
      }
      Button("Done", action: self.onDismiss)
        .buttonStyle(DefaultButtonStyle())
    }
      .padding()
      .frame(width: 200, alignment: .leading)
  }
}

#if DEBUG
struct PreferencesView_Preview: PreviewProvider {
  static var previews: some View {
    PreferencesView(onDismiss: {})
  }
}
#endif

final class PreferencesWindowController: NSWindowController {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(window: NSWindow?) {
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 800, height: 800),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered, defer: false)
    window.center()

    window.contentView = NSHostingView(rootView: PreferencesView(onDismiss: {
      window.sheetParent!.endSheet(window)
    }))
    super.init(window: window)
    self.window = window
  }
}