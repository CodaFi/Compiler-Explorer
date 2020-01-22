//
//  CompilationResult.swift
//  GodBolt
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

/// This model encapsulates the result of a single compilation.
public struct CompilationResult: Codable {

  /// A parsed compiler diagnostic.
  public struct Diagnostic: Codable {
    public let line: Int
    public let column: Int
    public let text: String
  }

  /// A single line in the compiler output.
  public struct IOStreamLine: Codable {

    /// The text of this line.
    public let text: String

    /// If this line is a compiler diagnostic, this property contains its location and text.
    public let tag: Diagnostic?
  }

  /// A single line in the generated assembly.
  public struct AssemblyLine: Codable {

    /// The corresponding location of this assembly instruction in the source code.
    public struct SourceLocation: Codable {
      public let file: String?
      public let line: Int
    }

    /// An assembly label.
    public struct Label: Codable {

      public struct Range: Codable {
        public let startCol: Int
        public let endCol: Int
      }

      /// The name of the label, for example: ".L2"
      public let name: String

      /// The range of the referenced label in this assembly line.
      public let range: Range
    }

    /// The text of this line.
    public let text: String

    /// The corresponding location of this assembly instruction in the source code.
    public let source: SourceLocation?

    /// The list of labels in this line, with their names and locations.
    public let labels: [Label]
  }

  /// The exit code of the compiler.
  public let code: Int32

  /// Whether we can cache the compilation result.
  public let okToCache: Bool

  public let stdout: [IOStreamLine]

  public let stderr: [IOStreamLine]

  public let inputFilename: String

  /// The complete list of compiler arguments.
  public let compilationOptions: [String]

  /// The size of the generated assembly in bytes.
  public let asmSize: Int

  /// The generated assembly.
  public let asm: [AssemblyLine]

  /// A mapping between label names and line numbers where they're declared.
  /// This is useful for making labels hyperlinks.
  public let labelDefinitions: [String : Int]
}
