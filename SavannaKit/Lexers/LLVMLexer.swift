///
///  LLVMLexer.swift
///  SavannaKit
///
///  Created by Robert Widmann on 8/3/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

#if os(iOS)
  import UIKit
#else
  import AppKit
#endif

public struct LLVMToken: UniversalToken {
  public enum LLVMTokenType {
    case keyword
    case plainText
    case operand
  }

  public let type: LLVMTokenType
  public let isEditorPlaceholder: Bool
  public let isPlain: Bool
  public let range: Range<String.Index>

  public static func formToken(_ word: String, in range: Range<String.Index>) -> LLVMToken {
    let type: LLVMToken.TokenType
    if keywordSet.contains(word) { type = .keyword }
    else if word.starts(with: "%") || word.starts(with: "!") { type = .operand }
    else { type = .plainText }
    return LLVMToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
  }
  
  public func foregroundColor(for type: LLVMTokenType) -> PlatformColor {
    switch type {
    case .keyword: return PlatformColor.blue
    case .operand: return PlatformColor.green
    case .plainText:
      #if os(macOS)
        let appearanceName = NSApp.effectiveAppearance.name
        if appearanceName == .darkAqua {
          return PlatformColor.white
        } else if appearanceName == .aqua {
          return PlatformColor.black
        } else {
          return PlatformColor.white
        }
      #else
        switch UIScreen.main.traitCollection.userInterfaceStyle {
        case .dark:
          return PlatformColor.white
        case .light:
          return PlatformColor.black
        default:
          return PlatformColor.white
        }
      #endif
    }
  }
}

private let keywordSet: Set<String> = [
  "fneg", "add", "fadd", "sub", "fsub", "mul", "fmul", "udiv", "sdiv", "fdiv", "urem", "srem",
  "frem", "shl", "lshr", "ashr", "and", "or", "xor", "icmp", "fcmp", "phi", "call", "trunc", "zext",
  "sext", "fptrunc", "fpext", "uitofp", "sitofp", "fptoui", "fptosi", "inttoptr", "ptrtoint",
  "bitcast", "addrspacecast", "select", "va_arg", "landingpad", "personality", "cleanup", "catch",
  "filter", "ret", "br", "switch", "indirectbr", "invoke", "resume", "unreachable", "cleanupret",
  "catchswitch", "catchret", "catchpad", "cleanuppad", "callbr", "alloca", "load", "store", "fence",
  "cmpxchg", "atomicrmw", "getelementptr", "extractelement", "insertelement", "shufflevector",
  "extractvalue", "insertvalue", "blockaddress",
]
