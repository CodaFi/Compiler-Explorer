//
//  AttributedText.swift
//  CompilerExplorer
//
//  Created by Sergej Jaskiewicz on 24.01.2020.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct AttributedText: View, Equatable {
  private let attributedString: NSAttributedString

  public init(_ attributedString: NSAttributedString) {
    self.attributedString = attributedString
  }

  public var body: some View {
    _AttributedText(attributedString: self.attributedString)
      .fixedSize()
  }

  public static func + (lhs: AttributedText, rhs: AttributedText) -> AttributedText {
    let mutableString = NSMutableAttributedString(attributedString: lhs.attributedString)
    mutableString.append(rhs.attributedString)
    return AttributedText(mutableString)
  }
}

#if canImport(UIKit)
private typealias PlatformColor = UIColor

private struct _AttributedText: UIViewRepresentable {

  typealias UIViewType = UILabel

  let attributedString: NSAttributedString

  func makeUIView(context: Context) -> UILabel {
    let label = UILabel()
    return label
  }

  func updateUIView(_ label: UILabel, context: Context) {
    label.attributedText = attributedString
  }
}
#elseif canImport(AppKit)
private typealias PlatformColor = NSColor

private struct _AttributedText: NSViewRepresentable {

  typealias NSViewType = NSTextField

  let attributedString: NSAttributedString

  func makeNSView(context: Context) -> NSTextField {
    let label = NSTextField()
    label.isEditable = false
    return label
  }

  func updateNSView(_ label: NSTextField, context: Context) {
    label.attributedStringValue = attributedString
  }
}
#endif


#if DEBUG
struct AttributedText_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      HStack {
        AttributedText(
          NSAttributedString(string: "Hello, ",
                             attributes: [.backgroundColor : PlatformColor.systemRed])
        )
        Text("world!")
      }
      AttributedText(
        NSAttributedString(string: "Hello!",
                           attributes: [.backgroundColor : PlatformColor.systemYellow])
      )
      AttributedText(
        NSAttributedString(string: "lorem ",
                           attributes: [.foregroundColor : PlatformColor.systemRed])
      ) + AttributedText(
        NSAttributedString(string: "ipsum",
                           attributes: [.foregroundColor : PlatformColor.systemBlue])
      )
    }
    .previewLayout(.sizeThatFits)
  }
}
#endif
