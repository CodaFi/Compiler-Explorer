//
//  ViewModel.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 7/27/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import SwiftUI
import Combine
import GodBolt
import SavannaKit

final class ViewModel: ObservableObject, Identifiable {
  private let client = Client.shared

  var objectWillChange = PassthroughSubject<Void, Never>()

  // FIXME: As for why there is a callback in the middle of my beautiful sea of
  // object binding outlets, let me tell you the tale of UIPageViewController:
  //
  // UIPageViewController was a quirky beast.  Built to handle reuse its own
  // way, always in control of cycling behavior.  This means that certain view
  // configurations are particularly unstable, even when not hosted inside
  // SwiftUI.  Our view configuration, being two non-cyclic views, should be
  // relatively stable.  However, SwiftUI's ideas about when the re-render the
  // view hierarchy confuse the reuse mechanism.  Simply binding the page
  // controller's index to a `Binding<Int>` reloads the page view controller and
  // causes it to "snap" back to the first index, or lose the page altogether.
  //
  // So, instead of having nice things, we need to splay the binding out into
  // a callback.  Maybe we'll get a UIPageViewController replacemesnt in the
  // next beta?
  var callback: ((String) -> Void)?

  /// The text value of the document.  Specifically does not call willChange
  /// because SavannaKit sends its "text did change" message quite frequently
  /// and we don't want to re-render more than necessary.
  @Published var documentTextValue: String = ""

  /// The text of the compiled form of `documentTextValue` subject to the
  /// filters and options below.
  ///
  /// This value changes as a direct response to mutations of any of the
  /// following properties.
  var compiledTextValue: String = "" {
     willSet {
       self.objectWillChange.send()
     }
  }

  /// The current language associated with this buffer.
  ///
  /// Documents with no extension and documents with an unknown extension
  /// will have a `nil` language.
  var language: Language? = nil {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// The suite of compilers available to the user.  This property changes in
  /// response to the language changing.
  var availableCompilers: [Compiler] = [] {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// An index into the `availableCompilers` array describing the currently
  /// selected compiler.
  @Published var selectedCompiler: Int = 0 {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// The user-provided options that the remote compiler consumes.
  @Published var compilerOptions: String = "" {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// An index describing the assembly syntax variant used to render the
  /// compiled code.
  ///
  /// 0 - Intel
  /// 1 - AT&T
  /// n - Crash
  @Published var syntax: Int = 0 {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// Whether to strip labels from the compiled code.
  @Published var labels: Bool = true {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// Whether to strip directives from the compiled code.
  @Published var directives: Bool = true {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// Whether to strip comment-only lines from the compiled code.
  @Published var comments: Bool = false {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// Whether to demangle symbols in the compiled code.  Also works with Swift
  /// symbols.
  @Published var demangle: Bool = false {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// Whether to trim whitespace in the compiled code.
  @Published var trim: Bool = false {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// The spine of the live-update mechanism.
  private var cancellable: AnyCancellable? = nil
  init() {
    /// Sink all of the live-update-relevant properties into one enormous
    /// publisher.  We debounce so we aren't overwhelming poor godbolt on every
    /// keystroke.
    self.cancellable = self.$documentTextValue
      .filter({ !$0.isEmpty })
      .combineLatest(self.$selectedCompiler, self.$compilerOptions) { $2 }
      .combineLatest(self.$syntax, self.$labels, self.$directives) { (compiler, syntax, labels, directives) -> Source.Options.Filter in
        var set = Source.Options.Filter(rawValue: 0)
        if syntax == 0 {
          set.formUnion(.intel)
        }
        if labels {
          set.formUnion(.labels)
        }
        if directives {
          set.formUnion(.directives)
        }
        return set
    }
    .combineLatest(self.$comments, self.$demangle, self.$trim) { (set, comments, demangle, trim) -> Source.Options.Filter in
      var set = set
      if comments {
        set.formUnion(.comments)
      }
      if demangle {
        set.formUnion(.demangle)
      }
      if trim {
        set.formUnion(.trim)
      }
      return set
    }
    .debounce(for: 0.5, scheduler: DispatchQueue.main)
    .filter({ _ in !self.availableCompilers.isEmpty })
    .flatMap { (filters) -> AnyPublisher<Response, Never> in
      let source = Source(source: self.documentTextValue,
                          options: .init(arguments: self.compilerOptions,
                                         filters: filters))
      return self.client.requestCompile(using: self.availableCompilers[self.selectedCompiler], of: source)
        .catch { error in Empty<Response, Never>() } // FIXME: This is hella incorrect
        .eraseToAnyPublisher()
    }
    .map { (values) -> String in values.asm.map({ $0.text }).joined(separator: "\n") }
    .receive(on: DispatchQueue.main)
    .sink { val in
      self.compiledTextValue = val
      self.callback?(val)
    }
  }
}


extension ViewModel {
  func compile() {
    let val = self.selectedCompiler
    self.selectedCompiler = val
  }

  // FIXME: This is disgusting
  func registerCompileCallback(_ callback: @escaping (String) -> Void) {
    self.callback = callback
  }

  func textDidChange(_ textView: SyntaxTextView) {
    self.documentTextValue = textView.text
  }

  func updateLanguage(_ lang: Language) {
    self.language = lang
    _ = self.client.requestCompilers(for: self.language)
      .catch { error in Empty() }
      .receive(on: DispatchQueue.main)
      .sink { values in
        self.availableCompilers = values
    }
  }
}
