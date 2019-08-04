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
import CompilerExplorerKit

struct PreferencesView: View {
  @EnvironmentObject var viewModel: ViewModel
  let onDismiss: () -> Void

  // FIXME: This definitely shouldn't be a sheet?
  var body: some View {
    VStack {
      GroupBox(label: Text("Preferences")) {
        Toggle("Live Compilation", isOn: self.$viewModel.liveCompile)
      }
      HStack {
        Spacer()
        NativeButton(title: "Done", keyEquivalent: "\r", action: self.onDismiss)
          .frame(width: 50)
      }
    }
      .padding()
      .frame(width: 200, alignment: .leading)
      .frame(height: 120)
  }
}

#if DEBUG
struct PreferencesView_Preview: PreviewProvider {
  static var previews: some View {
    PreferencesView(onDismiss: {}).environmentObject(ViewModel())
  }
}
#endif

final class PreferencesWindowController: NSWindowController {
  let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel

    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled, .closable, .miniaturizable, .resizable],
      backing: .buffered, defer: false)
    window.center()

    window.contentView = NSHostingView(rootView: PreferencesView(onDismiss: {
      window.sheetParent!.endSheet(window)
    }).environmentObject(self.viewModel))
    super.init(window: window)
    self.window = window
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
}
