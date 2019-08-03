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

// FIXME: All the lexers need to be consolidated.
public class AssemblyLexer: Lexer {
  public init() {}
  public func getSavannaTokens(input: String) -> [Token] {
    var tokens = [AssemblyToken]()
    input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) {
      (word, range, _, _) in
      guard let word = word?.lowercased() else { return }
      let type: AssemblyToken.TokenType
      if commonOpcodeSet.contains(word) { type = .opCode }
      else if commonOperandsSet.contains(word) { type = .operand }
      else if word.starts(with: "$") { type = .immediate }
      else if word.starts(with: ".") { type = .directive }
      else if word.contains(":") { type = .operand }
      else if word.starts(with: "%") || word.starts(with: "!") { type = .llvmOperand }
      else { type = .plainText }
      tokens.append(
        AssemblyToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range)
      )
    }
    return tokens
  }
}
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
  "cs", "ds", "es", "fs", "gs", "ss", "eflags", // ARM
  "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9", "r10", "r11", "r12", "r13", "r14",
  "r15", "cpsr",
]
private let commonOpcodeSet: Set<String> = [
  "mov", "add", "sub", "lea", "ret", "jmp", "div", "mul", "jsr", "ldx", "lda", "ldy", "rts", "cmp",
  "setl", "push", "pop", // LLVM
  "fneg", "add", "fadd", "sub", "fsub", "mul", "fmul", "udiv", "sdiv", "fdiv", "urem", "srem",
  "frem", "shl", "lshr", "ashr", "and", "or", "xor", "icmp", "fcmp", "phi", "call", "trunc", "zext",
  "sext", "fptrunc", "fpext", "uitofp", "sitofp", "fptoui", "fptosi", "inttoptr", "ptrtoint",
  "bitcast", "addrspacecast", "select", "va_arg", "landingpad", "personality", "cleanup", "catch",
  "filter", "ret", "br", "switch", "indirectbr", "invoke", "resume", "unreachable", "cleanupret",
  "catchswitch", "catchret", "catchpad", "cleanuppad", "callbr", "alloca", "load", "store", "fence",
  "cmpxchg", "atomicrmw", "getelementptr", "extractelement", "insertelement", "shufflevector",
  "extractvalue", "insertvalue", "blockaddress",
]
