///
///  ReadOnlyEditorViewWrapper.swift
///  Compiler Explorer
///
///  Created by Robert Widmann on 7/24/19.
///  Copyright © 2019 CodaFi. All rights reserved.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.


import SwiftUI
import Combine
import SavannaKit

struct ReadOnlyEditorViewWrapper: NSViewRepresentable {
  @Binding var text: String

  func makeNSView(context: NSViewRepresentableContext<ReadOnlyEditorViewWrapper>) -> SyntaxTextView {
    let syntaxView = SyntaxTextView(frame: .zero, lexer: TokenizingLexer<AssemblyToken>()) { _ in }
    syntaxView.contentTextView.isEditable = false
    syntaxView.theme = UniversalTheme<AssemblyToken>()
    syntaxView.text = self.text
    return syntaxView
  }

  func updateNSView(_ nsView: SyntaxTextView, context: NSViewRepresentableContext<ReadOnlyEditorViewWrapper>) {
    nsView.text = self.text
  }
}

#if DEBUG
struct ReadOnlyEditorViewWrapper_Preview: PreviewProvider {
  static var sampleText: String = """
    main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 48
        lea     rax, [rip + .L__unnamed_1]
        mov     ecx, 1
        mov     edx, ecx
        mov     ecx, 1
        mov     dword ptr [rbp - 28], edi
        mov     rdi, rax
        mov     qword ptr [rbp - 40], rsi
        mov     rsi, rdx
        mov     edx, ecx
        call    _TFSSCfT21_builtinStringLiteralBp17utf8CodeUnitCountBw7isASCIIBi1__SS@PLT
        mov     r8d, 5
        mov     esi, r8d
        mov     qword ptr [rbp - 24], rax
        mov     qword ptr [rbp - 16], rdx
        mov     qword ptr [rbp - 8], rcx
        mov     rdi, qword ptr [rbp - 24]
        mov     rax, qword ptr [rbp - 16]
        mov     rdx, qword ptr [rbp - 8]
        mov     qword ptr [rbp - 48], rsi
        mov     rsi, rax
        mov     rcx, qword ptr [rbp - 48]
        call    _TTSgq5SS___TFSaCfT9repeatingx5countSi_GSax_@PLT
        mov     rdi, rax
        call    swift_rt_swift_release
        xor     eax, eax
        add     rsp, 48
        pop     rbp
        ret
  """

  static var previews: some View {
    ReadOnlyEditorViewWrapper(text: .constant(self.sampleText))
  }
}
#endif
