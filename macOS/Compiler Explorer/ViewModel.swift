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

final class ViewModel: ObservableObject, Identifiable {
  private let client = Client.shared

  var objectWillChange = PassthroughSubject<Void, Never>()

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

  private var textView: SyntaxTextView?

  /// The spine of the live-update mechanism.
  private var cancellable: AnyCancellable? = nil
  init() {
    /// Sink all of the live-update-relevant properties into one enormous
    /// publisher.  We debounce so we aren't overwhelming poor godbolt on every
    /// keystroke.
    self.cancellable = self.$documentTextValue
      .filter({ !$0.isEmpty  })
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
      .assign(to: \.compiledTextValue, on: self)
  }
}

extension ViewModel {
  func updateFileExtension(_ ext: String) {
    self.objectWillChange.send()
    self.language = fileTypeTable[ext]
    _ = self.client.requestCompilers(for: self.language)
      .catch { error in Empty() }
      .receive(on: DispatchQueue.main)
      .sink { values in
        self.availableCompilers = values
      }
  }

  func readData(_ data: Data, ofType typeName: String) {
    let str = String(data: data, encoding: .utf8) ?? ""
    return self.readString(str, ofType: typeName, session: nil)
  }

  // FIXME: Fold this method into the other one.
  func readString(_ string: String, ofType typeName: String, session: SessionContainer.SessionCompiler?) {
    self.objectWillChange.send()
    self.textView?.text = string
    self.language = Language(id: typeName, name: "")
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

  func textDidChange(_ textView: SyntaxTextView) {
    self.textView = textView
    self.documentTextValue = textView.text
  }
}

// FIXME: Sync the many many tables in this thing somehow some way.
private let fileTypeTable: [String: Language] = [
  "c": Language.c, "m": Language.c,
  "f90": Language.fortran, "f95": Language.fortran, "f03": Language.fortran,
  "cpp": Language.cpp, "cc": Language.cpp, "cxx": Language.cpp, "h": Language.cpp, "hpp": Language.cpp, "mm": Language.cpp,
  "asm": Language.assembly, "s": Language.assembly,
  "cuda": Language.cuda,
  "llvm": Language.llvm, "ll": Language.llvm, "ir": Language.llvm,
  "d": Language.d,
  "go": Language.go,
  "rs": Language.rust,
  "icl": Language.clean, "dcl": Language.clean, "abc": Language.clean,
  "pas": Language.pascal,
  "hs": Language.haskell,
  "ada": Language.ada,
  "ml": Language.ocaml, "mli": Language.ocaml,
  "swift": Language.swift,
  "zig": Language.zig,
]
