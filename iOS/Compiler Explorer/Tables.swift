//
//  Tables.swift
//  Compiler Explorer
//
//  Created by Robert Widmann on 8/2/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

import GodBolt

enum ExtensionManager {
  static func fileExtension(for language: Language) -> String {
    return fileTypeTable[language] ?? ""
  }
}


private let fileTypeTable: [Language: String] = [
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
