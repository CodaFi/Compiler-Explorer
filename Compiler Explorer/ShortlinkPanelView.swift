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

struct ShortlinkPanelView: View {
  @EnvironmentObject var viewModel: ShortlinkWindowController
  let action: (NSApplication.ModalResponse) -> Void

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
    ShortlinkPanelView(action: { _ in })
  }
}
#endif

final class ShortlinkWindowController: NSWindowController, BindableObject {
  var willChange = PassthroughSubject<Void, Never>()

  // Example: https://godbolt.org/z/wsh6Oh
  private let shortlinkRegex = try! NSRegularExpression(pattern: "https?://godbolt.org/z/(\\w+$)")

  var shortlinkText: String = "" {
    willSet {
      self.willChange.send()
      self.errorText = " "
    }
  }
  var errorText: String = " " {
    willSet {
      self.willChange.send()
    }
  }
  var previousShortlinks: [String] = [] {
    willSet {
      self.willChange.send()
    }
  }
  var isValidatingShortlink: Bool = false {
    willSet {
      self.willChange.send()
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
    window.contentView = NSHostingView(rootView: ShortlinkPanelView() { response in
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

    let full = NSRange(location: 0, length: self.shortlinkText.count)
    guard let match = self.shortlinkRegex.firstMatch(in: self.shortlinkText, range: full) else {
      return false
    }

    guard match.numberOfRanges == 2 else {
      return false
    }

    let r = match.range(at: 1)
    let matchStart = self.shortlinkText.index(self.shortlinkText.startIndex,
                                         offsetBy: r.location)
    let matchEnd = self.shortlinkText.index(self.shortlinkText.startIndex,
                                       offsetBy: NSMaxRange(r))

    let substr = String(self.shortlinkText[
      Range<String.Index>(uncheckedBounds: (matchStart, matchEnd))
    ])

    let group = DispatchGroup()
    group.enter()
    self.validationCancellable = Client.shared
      .requestShortlinkInfo(for: substr)
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
