//
//  Language.swift
//  GodBolt
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

// N.B. Languages are unique by ID.  The display name is optional.
public struct Language: Codable, Hashable {
  public let id: String
  public let name: String

  public init(id: String, name: String) {
    self.id = id
    self.name = name
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }

  public static func == (lhs: Language, rhs: Language) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Language {
  public static let c = Language(id: "c", name: "C")
  public static let fortran = Language(id: "fortran", name: "Fortran")
  public static let cpp = Language(id: "c++", name: "C++")
  public static let cppx = Language(id: "cppx", name: "Cppx")
  public static let assembly = Language(id: "assembly", name: "Assembly")
  public static let cuda = Language(id: "cuda", name: "CUDA")
  public static let llvm = Language(id: "llvm", name: "LLVM IR")
  public static let d = Language(id: "d", name: "D")
  public static let ispc = Language(id: "ispc", name: "ispc")
  public static let analysis = Language(id: "analysis", name: "Analysis")
  public static let go = Language(id: "go", name: "Go")
  public static let rust = Language(id: "rust", name: "Rust")
  public static let clean = Language(id: "clean", name: "Clean")
  public static let pascal = Language(id: "pascal", name: "Pascal")
  public static let haskell = Language(id: "haskell", name: "Haskell")
  public static let ada = Language(id: "ada", name: "Ada")
  public static let ocaml = Language(id: "ocaml", name: "OCaml")
  public static let swift = Language(id: "swift", name: "Swift")
  public static let zig = Language(id: "zig", name: "Zig")
}
