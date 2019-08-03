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

  /// The text value of the document.  Specifically written as a subject
  /// because SavannaKit sends its "text did change" message quite frequently
  /// and we don't want to re-render more than necessary.
  var documentTextValue = CurrentValueSubject<String, Never>("")

  /// The text of the compiled form of `documentTextValue` subject to the
  /// filters and options below.
  ///
  /// This value changes as a direct response to mutations of any of the
  /// following properties.
  var compiledTextValue = CurrentValueSubject<String, Never>("")

  /// The current language associated with this buffer.
  ///
  /// Documents with no extension and documents with an unknown extension
  /// will have a `nil` language.
  var language: Language? = nil {
    willSet {
      self.objectWillChange.send()
    }
  }

  @Published var shortlinkValue: String = ""

  /// The suite of compilers available to the user.  This property changes in
  /// response to the language changing.
  var availableCompilers: [Compiler] = [] {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// An index into the `availableCompilers` array describing the currently
  /// selected compiler.
  @Published var selectedCompiler: Int = 0

  /// The user-provided options that the remote compiler consumes.
  @Published var compilerOptions: String = ""

  /// An index describing the assembly syntax variant used to render the
  /// compiled code.
  ///
  /// 0 - Intel
  /// 1 - AT&T
  /// n - Crash
  @Published var syntax: Int = 0

  /// Whether to strip labels from the compiled code.
  @Published var labels: Bool = true

  /// Whether to strip directives from the compiled code.
  @Published var directives: Bool = true

  /// Whether to strip comment-only lines from the compiled code.
  @Published var comments: Bool = false

  /// Whether to demangle symbols in the compiled code.  Also works with Swift
  /// symbols.
  @Published var demangle: Bool = false

  /// Whether to trim whitespace in the compiled code.
  @Published var trim: Bool = false

  /// The spine of the live-update mechanism.
  private var cancellable: AnyCancellable? = nil
  init() {
    /// Sink all of the live-update-relevant properties into one enormous
    /// publisher.  We debounce so we aren't overwhelming poor godbolt on every
    /// keystroke.
    self.cancellable = self.documentTextValue
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
      let source = Source(source: self.documentTextValue.value,
                          options: .init(arguments: self.compilerOptions,
                                         filters: filters))
      return self.client.requestCompile(using: self.availableCompilers[self.selectedCompiler], of: source)
        .catch { error in Empty<Response, Never>() } // FIXME: This is hella incorrect
        .eraseToAnyPublisher()
    }
    .map { (values) -> String in values.asm.map({ $0.text }).joined(separator: "\n") }
    .receive(on: DispatchQueue.main)
    .sink { val in
      self.compiledTextValue.send(val)
    }
  }
}


extension ViewModel {
  private func computeFilter() -> Source.Options.Filter {
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

  func textDidChange(_ textView: SyntaxTextView) {
    self.documentTextValue.send(textView.text)
  }

  func loadSession(_ session: SessionContainer.Session, compiler: SessionContainer.SessionCompiler) {
    self.objectWillChange.send()
    self.documentTextValue.send(session.source)
    self.language = ExtensionManager.language(for: session.language)
    _ = self.client.requestCompilers(for: self.language)
      .catch { error in Empty() }
      .receive(on: DispatchQueue.main)
      .sink { values in
        self.availableCompilers = values
        self.selectedCompiler = self.availableCompilers.firstIndex { ac in ac.id == compiler.id  } ?? 0
        self.compilerOptions = compiler.options
        self.syntax = compiler.filters.contains(.intel) ? 0 : 1
        self.labels = compiler.filters.contains(.labels)
        self.directives = compiler.filters.contains(.directives)
        self.comments = compiler.filters.contains(.comments)
        self.demangle = compiler.filters.contains(.demangle)
        self.trim = compiler.filters.contains(.trim)
      }
  }

  func updateLanguage(from url: URL) {
    self.language = ExtensionManager.language(for: url.pathExtension)
    _ = self.client.requestCompilers(for: self.language)
      .catch { error in Empty() }
      .receive(on: DispatchQueue.main)
      .sink { values in
        self.availableCompilers = values
    }
  }

  // FIXME: We can probably be lazier.
  func computeShortlinkForBuffer() {
    let compiler = self.availableCompilers[self.selectedCompiler]
    let source = Source(source: self.documentTextValue.value,
                        options: .init(arguments: self.compilerOptions,
                                       filters: self.computeFilter()))
    _ = self.client.requestShortString(using: compiler, of: source)
    .catch({ error in Empty() })
    .receive(on: DispatchQueue.main)
    .sink { shortlink in
      self.shortlinkValue = shortlink.url
    }
  }
}

