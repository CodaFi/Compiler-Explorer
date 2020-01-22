//
//  SpinnerView.swift
//  CompilerExplorerKit_iOS
//
//  Created by Sergej Jaskiewicz on 22.01.2020.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct SpinnerView: PlatformViewRepresentable {

#if canImport(UIKit)
  public typealias UIViewType = UIActivityIndicatorView
#elseif canImport(AppKit)
  public typealias NSViewType = NSProgressIndicator
#endif

  @Binding var isAnimating: Bool

  public init(isAnimating: Binding<Bool>) {
    _isAnimating = isAnimating
  }

  public func makePlatformView(context: Context) -> PlatformView {
#if canImport(UIKit)
    let view = PlatformView(style: .large)
#elseif canImport(AppKit)
    let view = PlatformView(frame: .zero)
    view.style = .spinning
#endif
    return view
  }

  public func updatePlatformView(_ platformView: PlatformView, context: Context) {
#if canImport(UIKit)
    if isAnimating {
      platformView.startAnimating()
    } else {
      platformView.stopAnimating()
    }
#elseif canImport(AppKit)
    if isAnimating {
      platformView.startAnimation(nil)
    } else {
      platformView.stopAnimation(nil)
    }
#endif
  }
}

