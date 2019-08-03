///
///  AssemblyLexer.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

#if os(iOS)
  import UIKit
#else
  import AppKit
#endif

public struct AssemblyToken: UniversalToken {
  public enum AssemblyTokenType {
    case opCode
    case immediate
    case operand
    case directive
    case plainText
    case llvmOperand
  }
  public let type: AssemblyTokenType
  public let isEditorPlaceholder: Bool
  public let isPlain: Bool
  public let range: Range<String.Index>

  public static func formToken(_ word: String, in range: Range<String.Index>) -> AssemblyToken {
    let word = word.lowercased()
    let type: AssemblyToken.TokenType
    if commonOpcodeSet.contains(word) { type = .opCode }
    else if commonOperandsSet.contains(word) { type = .operand }
    else if word.starts(with: "$") { type = .immediate }
    else if word.starts(with: ".") { type = .directive }
    else if word.contains(":") { type = .operand }
    else if word.starts(with: "%") || word.starts(with: "!") { type = .llvmOperand }
    else { type = .plainText }
    return AssemblyToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
  }

  public func foregroundColor(for type: AssemblyTokenType) -> PlatformColor {
    switch type {
    case .opCode: return PlatformColor.blue
    case .immediate: return PlatformColor.yellow
    case .operand: return PlatformColor.green
    case .llvmOperand: return PlatformColor.red
    case .directive: return PlatformColor.lightGray
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
private let commonOperandsSet: Set<String> = [
  // Intel
  "eax", "ebx", "ecx", "edx", "esi", "edi", "ebp", "eip", "esp", "rax", "rbx", "rcx", "rdx", "rsi",
  "rdi", "rbp", "rip", "rsp", "ax", "bx", "cx", "dx", "si", "di", "bp", "ip", "sp", "ah", "bh",
  "ch", "dh", "al", "bl", "cl", "dl", "sil", "dil", "bpl", "ipl", "sp", "ax", "bx", "cx", "dx",
  "cs", "ds", "es", "fs", "gs", "ss", "eflags",

  // ARM
  "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9", "r10", "r11", "r12", "r13", "r14",
  "r15", "cpsr",
]

private let commonOpcodeSet: Set<String> = [
  "mov", "add", "sub", "lea", "ret", "jmp", "div", "mul", "jsr", "ldx", "lda", "ldy", "rts", "cmp",
  "setl", "push", "pop",
]
