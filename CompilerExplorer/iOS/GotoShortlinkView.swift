//
//  ShortlinkPanelView.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 8/2/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import GodBolt

struct GotoShortlinkView: View {
  @EnvironmentObject var viewModel: GotoShortlinkViewModel
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
      VStack {
       TextField("https://godbolt.org/z/...",
            text: self.$viewModel.shortlinkText,
            onEditingChanged: { _ in },
            onCommit: { self.viewModel.react(self.presentationMode) })
        .disabled(self.viewModel.isValidatingShortlink)
        .textContentType(.URL)
        .keyboardType(.URL)
        .padding()
        Text(self.viewModel.errorText)
        Spacer()
      }
      .navigationBarTitle("Shortlink", displayMode: .large)
  }
}

#if DEBUG
struct GotoShortlinkView_Preview: PreviewProvider {
  static var previews: some View {
    GotoShortlinkView().environmentObject(GotoShortlinkViewModel(client: TestClient()))
  }
}
#endif

final class GotoShortlinkViewModel: ObservableObject, Identifiable {
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

  var shortlinkValue = CurrentValueSubject<SessionContainer?, Never>(nil)

  private var validationCancellable: AnyCancellable? = nil

  private let client: ClientProtocol

  init(client: ClientProtocol) {
    self.client = client
  }

  func react(_ dismiss: Binding<PresentationMode>) {
    guard self.validateShortlinkText() else {
      self.errorText = "Not a valid shortlink."
      return
    }
    self.resetAndClose(dismiss)
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
        print(err)
        return Empty<SessionContainer, Never>()
      }.sink(receiveCompletion: { _ in
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

  private func resetAndClose(_ dismiss: Binding<PresentationMode>) {
    self.validationCancellable?.cancel()
    self.shortlinkText = ""
    self.errorText = ""
    self.shortlinkValue.send(nil)
    dismiss.wrappedValue.dismiss()
  }
}

