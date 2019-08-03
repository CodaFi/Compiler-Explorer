///
///  ShortlinkPanelView.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/26/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import AppKit
import SwiftUI
import Combine
import GodBolt

struct GotoShortlinkPanelView: View {
  @EnvironmentObject var viewModel: GotoShortlinkWindowController
  let action: (NSApplication.ModalResponse) -> Void

  // N.B. Padding in this view is a little strange. Because these "Native"
  // controls are unknown to SwiftUI, if the padding is placed directly onto
  // them then they are rendered sans padding when in their first "empty" state.
  // This causes an unsightly "snap-to" effect when the user types.
  //
  // The choice to pad the whole HStack is very deliberate.
  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        Text("Go to shortlink:")
        NativeComboBox(title: "Enter a shortlink",
                       text: self.$viewModel.shortlinkText,
                       previous: self.$viewModel.previousShortlinks)
          .disabled(self.viewModel.isValidatingShortlink)
        HStack(alignment: .center) {
          Text(self.viewModel.errorText)
            .font(.system(size: 11))
          Spacer()
          NativeButton(title: "Cancel", keyEquivalent: "", action: {
            self.action(NSApplication.ModalResponse.cancel)
          })
            .frame(width: 80.0)
          NativeButton(title: "Go", keyEquivalent: "\r", action: {
            self.action(NSApplication.ModalResponse.OK)
          })
            .frame(width: 80.0)
            .disabled(self.viewModel.shortlinkText.isEmpty || self.viewModel.isValidatingShortlink)
        }
          .padding(.top, 16)
      }
    }
      .padding([ .leading, .trailing ], 20)
      .frame(width: 420, height: 125)
  }
}

#if DEBUG
struct ShortlinkPanelView_Preview: PreviewProvider {
  static var previews: some View {
    GotoShortlinkPanelView(action: { _ in })
  }
}
#endif

final class GotoShortlinkWindowController: NSWindowController, ObservableObject, Identifiable {
  var shortlinkText: String = "" {
    willSet {
      self.objectWillChange.send()
      self.errorText = " "
    }
  }
  var errorText: String = " " {
    willSet {
      self.objectWillChange.send()
    }
  }
  var previousShortlinks: [String] = [] {
    willSet {
      self.objectWillChange.send()
    }
  }
  var isValidatingShortlink: Bool = false {
    willSet {
      self.objectWillChange.send()
    }
  }

  private var shortlinkValue: SessionContainer? = nil
  func takeShortlinkValue() -> SessionContainer? {
    defer { self.shortlinkValue = nil }
    return self.shortlinkValue
  }

  private var validationCancellable: AnyCancellable? = nil

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(window: NSWindow?) {
    self.previousShortlinks = UserDefaults.standard.array(forKey: "PreviousShortlinks") as! [String]

    let window = NSWindow(
        contentRect: .zero,
        styleMask: [.titled],
        backing: .buffered, defer: false)
    window.center()

    window.title = "Go to shortlink"
    super.init(window: window)
    self.window = window
    window.contentView = NSHostingView(rootView: GotoShortlinkPanelView() { response in
      switch response {
      case .OK:
        guard self.validateShortlinkText() else {
          NSSound.beep()
          self.errorText = "Not a valid shortlink."
          return
        }
        self.writeShortLinkToDefaults()
        self.resetAndClose(response)
      case .cancel:
        self.validationCancellable?.cancel()
        self.resetAndClose(response)
      default:
        fatalError()
      }
    }
      .environmentObject(self))
  }

  // FIXME: We definitely want some kind of indeterminate progress bar here
  // at some point.  Perhaps SwiftUI will provide in a future beta...
  private func validateShortlinkText() -> Bool {
    self.isValidatingShortlink = true
    defer { self.isValidatingShortlink = false }

    guard let url = URL(string: self.shortlinkText) else { return false }
    guard let host = url.host, host.contains("godbolt.org") else { return false }
    guard url.pathComponents.count == 3 else { return false }
    guard url.path.contains("z") else { return false }

    let group = DispatchGroup()
    group.enter()
    self.validationCancellable = Client.shared
      .requestShortlinkInfo(for: url.lastPathComponent)
      .catch { err -> Empty<SessionContainer, Never> in print(err); return Empty<SessionContainer, Never>() }
      .sink(receiveCompletion: { _ in
        group.leave()
      }) { value in
        self.shortlinkValue = value
      }

    switch group.wait(timeout: DispatchTime.now().advanced(by: .seconds(10))) {
    case .success:
      return self.shortlinkValue != nil
    case .timedOut:
      return false
    }
  }

  private func writeShortLinkToDefaults() {
    var array = self.previousShortlinks
    array.insert(self.shortlinkText, at: 0)
    if array.count > 5 {
      array.removeLast()
    }
    self.previousShortlinks = array
    UserDefaults.standard.setValue(array, forKey: "PreviousShortlinks")
  }

  private func resetAndClose(_ response: NSApplication.ModalResponse) {
    self.validationCancellable?.cancel()
    self.shortlinkText = ""
    self.errorText = ""
    NSApp.stopModal(withCode: response)
    self.window!.close()
  }
}
