//
//  Tables.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 8/3/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

public enum ExtensionManager {
  public static func language(for extension: String) -> Language? {
    return fileTypeTable[`extension`]
  }

  public static func fileExtension(for language: Language) -> String {
    return fileExtensionTable[language] ?? ""
  }
}


private let fileExtensionTable: [Language: String] = [
  Language.c: "c",
  Language.fortran: "f03",
  Language.cpp: "cpp",
  Language.assembly: "asm",
  Language.cuda: "cuda",
  Language.llvm: "llvm",
  Language.d: "d",
  Language.go: "go",
  Language.rust: "rs",
  Language.clean: "icl",
  Language.pascal: "pas",
  Language.haskell: "hs",
  Language.ada: "ada",
  Language.ocaml: "ml",
  Language.swift: "swift",
  Language.zig: "zig",
]

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


