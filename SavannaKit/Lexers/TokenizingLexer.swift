//
//  UniversalLexer.swift
//  SavannaKit
//
//  Created by Robert Widmann on 8/3/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

public final class TokenizingLexer<TokenType: UniversalToken>: Lexer {
  public init() {}
  
  public func getSavannaTokens(input: String) -> [Token] {
    var tokens = [TokenType]()
    input.enumerateSubstrings(in: input.startIndex..<input.endIndex, options: [.byWords]) {
      (word, range, _, _) in
      guard let word = word else { return }
      tokens.append(TokenType.formToken(word, in: range))
    }
    return tokens
  }
}
