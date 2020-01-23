//
//  SearchBar.swift
//  CompilerExplorer_iOS
//
//  Created by Sergej Jaskiewicz on 23.01.2020.
//

import SwiftUI
import UIKit

struct SearchBar: View {

  @Binding private var text: String

  private var autocapitalizationType: UITextAutocapitalizationType

  init(text: Binding<String>,
       autocapitalizationType: UITextAutocapitalizationType = .sentences) {
    _text = text
    self.autocapitalizationType = autocapitalizationType
  }

  var body: some View {
    _SearchBar(text: $text, autocapitalizationType: autocapitalizationType)
  }
}

private struct _SearchBar: UIViewRepresentable {

  @Binding var text: String

  var autocapitalizationType: UITextAutocapitalizationType

  final class Coordinator: NSObject, UISearchBarDelegate {

    @Binding var text: String

    init(text: Binding<String>) {
      _text = text
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      text = searchText
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(text: _text)
  }

  func makeUIView(context: Context) -> UISearchBar {
    let searchBar = UISearchBar(frame: .zero)
    searchBar.autocapitalizationType = autocapitalizationType
    searchBar.delegate = context.coordinator
    return searchBar
  }

  func updateUIView(_ uiView: UISearchBar, context: Context) {
    uiView.text = text
  }
}

#if DEBUG
struct SearchBar_Previews: PreviewProvider {
  static var previews: some View {
    SearchBar(text: .constant("hello!"))
      .previewLayout(.sizeThatFits)
  }
}
#endif
