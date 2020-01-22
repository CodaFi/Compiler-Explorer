//
//  Data+PrettyPrintJSON.swift
//  Compiler-Explorer
//
//  Created by Sergej Jaskiewicz on 22.01.2020.
//

import Foundation

extension Data {
  func prettyPrintedJSON() -> String {
    let result: Data
    do {
      let json = try JSONSerialization.jsonObject(with: self)
      result = try JSONSerialization.data(withJSONObject: json,
                                          options: [.prettyPrinted, .sortedKeys])
    } catch {
      result = self
    }
    return String(decoding: result, as: UTF8.self)
  }
}
