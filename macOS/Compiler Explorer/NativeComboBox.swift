//
//  NativeComboBox.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/26/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import Combine

struct NativeComboBox: NSViewRepresentable {
  let title: String
  @Binding var comboTextBinding: String
  @Binding var previousShortlinkBinding: [String]

  init(title: String, text: Binding<String>, previous: Binding<[String]>) {
    self.title = title
    self._comboTextBinding = text
    self._previousShortlinkBinding = previous
  }

  @objc final class Coordinator: NSObject, NSComboBoxDelegate, NSComboBoxDataSource {
    let parent: NativeComboBox
    var hasBeenMadeFirstResponder = false

    init(_ parent: NativeComboBox) {
      self.parent = parent
    }

    func controlTextDidChange(_ notification: Notification) {
      guard let object = notification.object else {
        return
      }

      guard let box = object as? NSComboBox else {
        return
      }

      self.parent.comboTextBinding = box.stringValue
      box.reloadData()
    }

    func comboBoxSelectionDidChange(_ notification: Notification) {
      guard let object = notification.object else {
        return
      }

      guard let box = object as? NSComboBox else {
        return
      }

      self.parent.comboTextBinding = self.parent.previousShortlinkBinding[box.indexOfSelectedItem]
      box.reloadData()
    }

    func numberOfItems(in comboBox: NSComboBox) -> Int {
      return self.parent.previousShortlinkBinding.count
    }

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
      return self.parent.previousShortlinkBinding[index]
    }
  }

  final class SingleLineFormatter: Formatter {
    override func getObjectValue(
      _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
      for string: String,
      errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
      if let objectRef = obj {
        objectRef.pointee = string as NSString
      }
      return true
    }

    override func string(for obj: Any?) -> String? {
      guard let object = obj else {
        return nil
      }
      return object as? String
    }

    override func isPartialStringValid(
      _ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>,
      proposedSelectedRange proposedSelRangePtr: NSRangePointer?,
      originalString origString: String,
      originalSelectedRange origSelRange: NSRange,
      errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
      guard let proposedSelRangePtr = proposedSelRangePtr else {
        return true
      }

      let charLoc = proposedSelRangePtr.pointee.location
      guard charLoc > 0 else {
        return true
      }

      let charValue = partialStringPtr.pointee.character(at: charLoc - 1)
      guard let scalarValue = Unicode.Scalar(charValue) else {
        return true
      }

      if CharacterSet.newlines.contains(scalarValue) {
        error?.pointee = nil
        return false
      }

      return true
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  func makeNSView(context: NSViewRepresentableContext<NativeComboBox>) -> NSComboBox {
    let box = NSComboBox(string: "")
    box.placeholderString = self.title
    box.usesDataSource = true
    box.delegate = context.coordinator
    box.dataSource = context.coordinator
    box.maximumNumberOfLines = 1
    box.formatter = SingleLineFormatter()
    return box
  }

  func updateNSView(_ comboBox: NSComboBox, context: NSViewRepresentableContext<NativeComboBox>) {
    // WEWLAD: This not only DOES NOT WORK, it makes SwiftUI furious.
//    if !context.coordinator.hasBeenMadeFirstResponder && comboBox.window != nil {
//      context.coordinator.hasBeenMadeFirstResponder = true
//      comboBox.becomeFirstResponder()
//    }
    if comboBox.stringValue != self.comboTextBinding {
      comboBox.stringValue = self.comboTextBinding
      comboBox.reloadData()
    }
  }
}

#if DEBUG
struct NativeComboBox_Preview: PreviewProvider {
  static var previews: some View {
    NativeComboBox(title: "", text: .constant(""), previous: .constant([]))
  }
}
#endif
