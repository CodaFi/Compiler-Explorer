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
  @EnvironmentObject var viewModel: GotoShortlinkWindowController.ViewModel

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
            self.viewModel.shortlinkPanelAction(.cancel)
          })
            .frame(width: 80.0)
          NativeButton(title: "Go", keyEquivalent: "\r", action: {
            self.viewModel.shortlinkPanelAction(.OK)
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
    GotoShortlinkPanelView()
      .environmentObject(GotoShortlinkWindowController.ViewModel(client: TestClient()))
  }
}
#endif

final class GotoShortlinkWindowController: NSWindowController {

  final class ViewModel: ObservableObject, Identifiable {
    @Published var errorText: String = ""
    @Published var shortlinkText: String = ""
    @Published var previousShortlinks: [String] = []
    @Published var isValidatingShortlink: Bool = false
    var shortlinkValue = CurrentValueSubject<SessionContainer?, Never>(nil)
    fileprivate var validationCancellable: AnyCancellable? = nil

    private let client: ClientProtocol

    init(client: ClientProtocol) {
      self.client = client
      self.previousShortlinks = UserDefaults.standard.array(forKey: "PreviousShortlinks") as! [String]
    }
  }

  let viewModel: ViewModel

  init(client: ClientProtocol) {
    self.viewModel = ViewModel(client: client)
    let window = NSWindow(
        contentRect: .zero,
        styleMask: [.titled],
        backing: .buffered, defer: false)
    window.center()

    window.title = "Go to shortlink"
    super.init(window: window)
    self.window = window
    window.contentView = NSHostingView(rootView: GotoShortlinkPanelView().environmentObject(self.viewModel))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension GotoShortlinkWindowController.ViewModel {
  func shortlinkPanelAction(_ response: NSApplication.ModalResponse) {
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
    self.validationCancellable = client
      .requestShortlinkInfo(for: url.lastPathComponent)
      .catch { err -> Empty<SessionContainer, Never> in
        print(err) // FIXME: Properly handle the error
        return Empty<SessionContainer, Never>()
      }
      .sink(receiveCompletion: { _ in
        group.leave()
      }) { value in
        self.shortlinkValue.send(value)
      }

    switch group.wait(timeout: DispatchTime.now().advanced(by: .seconds(10))) {
    case .success:
      return self.shortlinkValue.value != nil
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
    self.shortlinkValue.send(nil)
    NSApp.modalWindow!.close()
    NSApp.stopModal(withCode: response)
  }
}
