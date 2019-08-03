//
//  Types.swift
//  SavannaKit
//
//  Created by Louis D'hauwe on 24/06/2017.
//  Copyright © 2017 Silver Fox. All rights reserved.
//
import Foundation

#if os(macOS)
  import AppKit
  public typealias PlatformView = NSView
  public typealias PlatformViewController = NSViewController
  public typealias PlatformWindow = NSWindow
  public typealias PlatformControl = NSControl
  public typealias PlatformTextView = NSTextView
  public typealias PlatformTextField = NSTextField
  public typealias PlatformButton = NSButton
  public typealias PlatformFont = NSFont
  public typealias PlatformColor = NSColor
  public typealias PlatformStackView = NSStackView
  public typealias PlatformImage = NSImage
  public typealias PlatformBezierPath = NSBezierPath
  public typealias PlatformScrollView = NSScrollView
  public typealias PlatformScreen = NSScreen
#else
  import UIKit
  public typealias PlatformView = UIView
  public typealias PlatformViewController = UIViewController
  public typealias PlatformWindow = UIWindow
  public typealias PlatformControl = UIControl
  public typealias PlatformTextView = UITextView
  public typealias PlatformTextField = UITextField
  public typealias PlatformButton = UIButton
  public typealias PlatformFont = UIFont
  public typealias PlatformColor = UIColor
  public typealias PlatformStackView = UIStackView
  public typealias PlatformImage = UIImage
  public typealias PlatformBezierPath = UIBezierPath
  public typealias PlatformScrollView = UIScrollView
  public typealias PlatformScreen = UIScreen
#endif
