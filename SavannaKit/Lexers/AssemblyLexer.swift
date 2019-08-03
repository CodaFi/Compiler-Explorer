///
///  AssemblyLexer.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

// FIXME: All the lexers need to be consolidated.
public class AssemblyLexer: Lexer {

  public init() {}

  public func getSavannaTokens(input: String) -> [Token] {
    var tokens = [AssemblyToken]()

    input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) { (word, range, _, _) in
      guard let word = word?.lowercased() else {
        return
      }

      let type: AssemblyTokenType
      if commonOpcodeSet.contains(word) {
        type = .opCode
      } else if commonOperandsSet.contains(word) {
        type = .operand
      } else if word.starts(with: "$") {
        type = .immediate
      } else if word.starts(with: ".") {
        type = .directive
      } else if word.contains(":") {
        type = .operand
      } else if word.starts(with: "%") || word.starts(with: "!") {
        type = .llvmOperand
      } else {
        type = .plainText
      }

      tokens.append(AssemblyToken(type: type, isEditorPlaceholder: false, isPlain: false, range: range))
    }
    return tokens
  }
}

enum AssemblyTokenType {
  case opCode
  case immediate
  case operand
  case directive
  case plainText
  case llvmOperand
}

struct AssemblyToken: Token {
  let type: AssemblyTokenType
  let isEditorPlaceholder: Bool
  let isPlain: Bool
  let range: Range<String.Index>
}

private let commonOperandsSet: Set<String> = [
  // Intel
  "eax", "ebx", "ecx", "edx", "esi", "edi", "ebp", "eip", "esp",
  "rax", "rbx", "rcx", "rdx", "rsi", "rdi", "rbp", "rip", "rsp",
  "ax", "bx", "cx", "dx", "si", "di", "bp", "ip", "sp",
  "ah", "bh", "ch", "dh", "al", "bl", "cl", "dl",
  "sil", "dil", "bpl", "ipl", "sp",

  "ax", "bx", "cx", "dx",
  "cs", "ds", "es", "fs", "gs", "ss", "eflags",

  // ARM
  "r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9", "r10", "r11", "r12", "r13", "r14", "r15", "cpsr",
]

private let commonOpcodeSet: Set<String> = [
  "mov", "add", "sub", "lea", "ret", "jmp", "div", "mul",
  "jsr", "ldx", "lda", "ldy", "rts", "cmp", "setl", "push", "pop",

  // LLVM
  "fneg",
  "add",
  "fadd",
  "sub",
  "fsub",
  "mul",
  "fmul",
  "udiv",
  "sdiv",
  "fdiv",
  "urem",
  "srem",
  "frem",
  "shl",
  "lshr",
  "ashr",
  "and",
  "or",
  "xor",
  "icmp",
  "fcmp",
  "phi",
  "call",
  "trunc",
  "zext",
  "sext",
  "fptrunc",
  "fpext",
  "uitofp",
  "sitofp",
  "fptoui",
  "fptosi",
  "inttoptr",
  "ptrtoint",
  "bitcast",
  "addrspacecast",
  "select",
  "va_arg",
  "landingpad",
  "personality",
  "cleanup",
  "catch",
  "filter",
  "ret",
  "br",
  "switch",
  "indirectbr",
  "invoke",
  "resume",
  "unreachable",
  "cleanupret",
  "catchswitch",
  "catchret",
  "catchpad",
  "cleanuppad",
  "callbr",
  "alloca",
  "load",
  "store",
  "fence",
  "cmpxchg",
  "atomicrmw",
  "getelementptr",
  "extractelement",
  "insertelement",
  "shufflevector",
  "extractvalue",
  "insertvalue",
  "blockaddress",
]

public class AssemblyTheme: SyntaxColorTheme {
  public init() {
  }

  private static var lineNumbersColor: PlatformColor {
    return PlatformColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
  }

  public let lineNumbersStyle: LineNumbersStyle? = LineNumbersStyle(font: PlatformFont(name: "Menlo", size: 16)!, textColor: lineNumbersColor)
  public let gutterStyle: GutterStyle = GutterStyle(backgroundColor: PlatformColor(red: 21/255.0, green: 22/255, blue: 31/255, alpha: 1.0), minimumWidth: 32)

  public let font = PlatformFont(name: "Menlo", size: 15)!

  public let backgroundColor = PlatformColor(red: 31/255.0, green: 32/255, blue: 41/255, alpha: 1.0)

  public func globalAttributes() -> [NSAttributedString.Key: Any] {

    var attributes = [NSAttributedString.Key: Any]()

    attributes[.font] = PlatformFont(name: "Menlo", size: 15)!
    attributes[.foregroundColor] = PlatformColor.white

    return attributes
  }

  public func attributes(for token: Token) -> [NSAttributedString.Key: Any] {

    guard let myToken = token as? AssemblyToken else {
      return [:]
    }

    var attributes = [NSAttributedString.Key: Any]()

    switch myToken.type {
    case .opCode:
      attributes[.foregroundColor] = PlatformColor.cyan
    case .immediate:
      attributes[.foregroundColor] = PlatformColor.yellow
    case .operand:
      attributes[.foregroundColor] = PlatformColor.green
    case .llvmOperand:
      attributes[.foregroundColor] = PlatformColor.red
    case .directive:
      attributes[.foregroundColor] = PlatformColor.lightGray
    case .plainText:
      attributes[.foregroundColor] = PlatformColor.white
    }

    return attributes
  }

}
