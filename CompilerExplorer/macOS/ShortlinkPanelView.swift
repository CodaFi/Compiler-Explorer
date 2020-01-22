///
///  ShortlinkPanelView.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 8/3/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import SwiftUI
import GodBolt
import CompilerExplorerKit

struct ShortlinkPanelView: View {
  @EnvironmentObject var viewModel: ViewModel
  let onDismiss: () -> Void

  var body: some View {
    VStack(alignment: .leading) {
      Text("Copy Shortlink:")
        .padding([ .leading, .trailing, .top ], 22.0)
      NativeCopyableTextField(string: self.$viewModel.shortlinkValue, placeholder: "Loading...")
        .padding([ .leading, .trailing ], 22.0)
      HStack(alignment: .center) {
        Spacer()
        NativeShareButton()
          .padding([ .bottom ], 22.0)
          .frame(width: 50.0)
        NativeButton(title: "OK", keyEquivalent: "\r", action: {
          self.onDismiss()
        })
          .padding([ .trailing, .bottom ], 22.0)
          .frame(width: 100.0)
      }
    }
      .disabled(self.viewModel.shortlinkValue.isEmpty)
      .frame(width: 275.0)
  }
}

#if DEBUG
struct ShortlinkPanelView_Previews: PreviewProvider {
  static var previews: some View {
    ShortlinkPanelView(onDismiss: {}).environmentObject(ViewModel())
  }
}
#endif

final class ShortlinkWindowController: NSWindowController, ObservableObject, Identifiable {
  let viewModel: ViewModel

  init(viewModel: ViewModel) {
    self.viewModel = viewModel
    let window = NSWindow(
      contentRect: .zero,
      styleMask: [.titled],
      backing: .buffered, defer: false)

    window.title = "Go to shortlink"
    super.init(window: window)
    self.window = window
    window.contentView = NSHostingView(rootView: ShortlinkPanelView() {
      NSApp?.stopModal(withCode: NSApplication.ModalResponse.OK)
      window.sheetParent!.endSheet(window)
    }.environmentObject(self.viewModel))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }
}
