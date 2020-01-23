//
//  SearchListView.swift
//  CompilerExplorerKit_iOS
//
//  Created by Sergej Jaskiewicz on 23.01.2020.
//

import SwiftUI
import UIKit
import StringSearch

struct SearchListView: View {

  private let elements: [String]

  @State private var searchQuery: String = ""

  @Binding private var selection: Int?

  init(_ elements: [String], selection: Binding<Int?>) {
    self.elements = elements
    self._selection = selection
  }

  private var searchResults: [(Int, SearchResult<String>)] {
    StringSearch.searchIgnoringCase(for: searchQuery, in: elements)
  }

  private func attributedString(for result: SearchResult<String>) -> NSAttributedString {
    let attributedString = NSMutableAttributedString(string: result.content)
    for range in result.matchingCollectionRanges {
      attributedString.addAttribute(.backgroundColor,
                                    value: UIColor(named: "SearchTextMatchBackgroundColor")!,
                                    range: NSRange(range, in: result.content))
    }
    return attributedString
  }

  var body: some View {
    VStack(spacing: 0) {
      SearchBar(text: $searchQuery)
      List(searchResults, id: \.0, selection: $selection) { _, result in
        AttributedText(self.attributedString(for: result))
      }
    }
  }
}

#if DEBUG
struct SearchListView_Previews: PreviewProvider {
  static var previews: some View {
    SearchListView(["C",
                    "Fortran",
                    "C++",
                    "Cppx",
                    "Assembly",
                    "CUDA",
                    "Python",
                    "LLVM IR",
                    "D",
                    "ispc",
                    "Analysis",
                    "Nim",
                    "Go",
                    "Rust",
                    "Clean",
                    "Pascal",
                    "Haskell",
                    "Ada",
                    "OCaml",
                    "Swift",
                    "Zig"],
                   selection: .constant(nil))
  }
}
#endif
