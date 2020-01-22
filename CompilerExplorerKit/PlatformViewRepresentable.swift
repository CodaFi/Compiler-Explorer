//
//  PlatformViewRepresentable.swift
//  CompilerExplorerKit_iOS
//
//  Created by Sergej Jaskiewicz on 22.01.2020.
//

import SwiftUI

#if canImport(UIKit)
import UIKit

public protocol PlatformViewRepresentable: UIViewRepresentable {
  func makePlatformView(context: Context) -> PlatformView
  func updatePlatformView(_ platformView: PlatformView, context: Context)
  static func dismantlePlatformView(_ platformView: PlatformView, coordinator: Coordinator)
}

extension PlatformViewRepresentable {

  public typealias PlatformView = UIViewType

  public func makeUIView(context: Context) -> UIViewType {
    makePlatformView(context: context)
  }

  public func updateUIView(_ uiView: UIViewType, context: Context) {
    updatePlatformView(uiView, context: context)
  }

  public static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
    dismantlePlatformView(uiView, coordinator: coordinator)
  }
}

#elseif canImport(AppKit)
import AppKit

public protocol PlatformViewRepresentable: NSViewRepresentable {
  func makePlatformView(context: Context) -> PlatformView
  func updatePlatformView(_ platformView: PlatformView, context: Context)
  static func dismantlePlatformView(_ platformView: PlatformView, coordinator: Coordinator)
}

extension PlatformViewRepresentable {

  public typealias PlatformView = NSViewType

  public func makeNSView(context: Context) -> NSViewType {
    makePlatformView(context: context)
  }

  public func updateNSView(_ nsView: NSViewType, context: Context) {
    updatePlatformView(nsView, context: context)
  }

  public static func dismantleNSView(_ nsView: NSViewType, coordinator: Coordinator) {
    dismantlePlatformView(nsView, coordinator: coordinator)
  }
}

#else
#error("Unsupported Platform")
#endif

extension PlatformViewRepresentable {
  public static func dismantlePlatformView(_ platformView: PlatformView,
                                           coordinator: Coordinator) {}
}
