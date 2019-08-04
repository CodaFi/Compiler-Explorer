///
///  ViewModel.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import GodBolt
import Combine
import SwiftUI
import SavannaKit

public final class ViewModel: ObservableObject, Identifiable {
  private let client = Client.shared

  /// The text value of the document.  Specifically written as a subject
  /// because SavannaKit sends its "text did change" message quite frequently
  /// and we don't want to re-render more than necessary.
  public var documentTextValue = CurrentValueSubject<String, Never>("")

  /// The text of the compiled form of `documentTextValue` subject to the
  /// filters and options below.
  ///
  /// This value changes as a direct response to mutations of any of the
  /// following properties.
  public var compiledTextValue = CurrentValueSubject<String, Never>("")

  /// The current language associated with this buffer.
  ///
  /// Documents with no extension and documents with an unknown extension
  /// will have a `nil` language.
  public var language: Language? = nil {
    willSet {
      self.objectWillChange.send()
    }
  }

  /// The suite of compilers available to the user.  This property changes in
  /// response to the language changing.
  public var availableCompilers: [Compiler] = [] {
    willSet {
      self.objectWillChange.send()
    }
  }

  @Published public var shortlinkValue: String = ""

  /// An index into the `availableCompilers` array describing the currently
  /// selected compiler.
  @Published public var selectedCompiler: Int = 0
  

  /// The user-provided options that the remote compiler consumes.
  @Published public var compilerOptions: String = ""

  /// An index describing the assembly syntax variant used to render the
  /// compiled code.
  ///
  /// 0 - Intel
  /// 1 - AT&T
  /// n - Crash
  @Published public var syntax: Int = 0

  /// Whether to strip labels from the compiled code.
  @Published public var labels: Bool = true

  /// Whether to strip directives from the compiled code.
  @Published public var directives: Bool = true

  /// Whether to strip comment-only lines from the compiled code.
  @Published public var comments: Bool = false

  /// Whether to demangle symbols in the compiled code.  Also works with Swift
  /// symbols.
  @Published public var demangle: Bool = false

  /// Whether to trim whitespace in the compiled code.
  @Published public var trim: Bool = false

  /// Whether or not compilation is live.
  @Published public var liveCompile: Bool = true

  /// If true, ignore the "live compile" setting and force recompilation.
  private var forceRecompile: Bool = false

  private var textView: SyntaxTextView?

  /// The spine of the live-update mechanism.
  private var cancellable: AnyCancellable? = nil
  public init() {
    /// Sink all of the live-update-relevant properties into one enormous
    /// publisher.  We debounce so we aren't overwhelming poor godbolt on every
    /// keystroke.
    self.cancellable = self.documentTextValue
      .filter({ _ in self.liveCompile || self.forceRecompile })
      .filter({ !$0.isEmpty  })
      .combineLatest(self.$selectedCompiler, self.$compilerOptions) { $2 }
      .combineLatest(self.$syntax, self.$labels, self.$directives) { _,_,_,_ in () }
      .combineLatest(self.$comments, self.$demangle, self.$trim) { _,_,_,_ in () }
      .map { _ in self.computeFilter() }
      .handleEvents(receiveOutput: { _ in self.shortlinkValue = "" }) // reset the shortlink.
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
      .sink { self.compiledTextValue.send($0) }
  }
}

#if os(macOS)
extension ViewModel {
  public func recompile() {
    self.forceRecompile = true
    defer { self.forceRecompile = false }
    let value = self.documentTextValue.value
    self.documentTextValue.send(value)
  }

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

  // FIXME: We can probably be lazier.
  public func computeShortlinkForBuffer() {
    guard self.shortlinkValue.isEmpty else {
      return
    }
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

  public func updateFileExtension(_ ext: String) {
    self.objectWillChange.send()
    self.language = ExtensionManager.language(for: ext)
    _ = self.client.requestCompilers(for: self.language)
      .catch { error in Empty() }
      .receive(on: DispatchQueue.main)
      .sink { values in
        self.availableCompilers = values
      }
  }

  public func readData(_ data: Data, ofType typeName: String) {
    let str = String(data: data, encoding: .utf8) ?? ""
    return self.readString(str, ofType: typeName, session: nil)
  }

  // FIXME: Fold this method into the other one.
  public func readString(_ string: String, ofType ext: String, session: SessionContainer.SessionCompiler?) {
    self.objectWillChange.send()
    self.documentTextValue.send(string)
    self.textView?.text = string
    self.language = ExtensionManager.language(for: ext)
    _ = self.client.requestCompilers(for: self.language)
      .catch { error in Empty() }
      .receive(on: DispatchQueue.main)
      .sink { values in
        self.availableCompilers = values
        // Session restoration
        if let session = session {
          self.selectedCompiler = self.availableCompilers.firstIndex { compiler in compiler.id == session.id  } ?? 0
          self.compilerOptions = session.options
          self.syntax = session.filters.contains(.intel) ? 0 : 1
          self.labels = session.filters.contains(.labels)
          self.directives = session.filters.contains(.directives)
          self.comments = session.filters.contains(.comments)
          self.demangle = session.filters.contains(.demangle)
          self.trim = session.filters.contains(.trim)
        }
      }
  }

  public func textDidChange(_ textView: SyntaxTextView) {
    self.textView = textView
    self.documentTextValue.send(textView.text)
  }
}
#elseif os(iOS)
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

  public func textDidChange(_ textView: SyntaxTextView) {
    self.documentTextValue.send(textView.text)
  }

  public func loadSession(_ session: SessionContainer.Session, compiler: SessionContainer.SessionCompiler) {
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

  public func updateLanguage(from url: URL) {
    self.language = ExtensionManager.language(for: url.pathExtension)
    _ = self.client.requestCompilers(for: self.language)
      .catch { error in Empty() }
      .receive(on: DispatchQueue.main)
      .sink { values in
        self.availableCompilers = values
    }
  }

  public func computeShortlinkForBuffer() {
    guard self.shortlinkValue.isEmpty else {
      return
    }
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
#else
#error("Unsupported Platform")
#endif
