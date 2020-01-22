//
//  URLRequest+RawDescription.swift
//  Compiler-Explorer
//
//  Created by Sergej Jaskiewicz on 22.01.2020.
//

import Foundation

extension URLRequest {
  var rawDescription: String {
    let endpoint = "\(httpMethod ?? "GET") \(url?.absoluteString ?? "(null)")"
    let headers = (allHTTPHeaderFields ?? [:])
      .lazy
      .map { "\($0): \($1)" }
      .sorted()
    var result = ""
    print(endpoint, to: &result)
    for header in headers {
      print(header, to: &result)
    }
    if let bodyString = httpBody?.prettyPrintedJSON() {
      print(bodyString, to: &result)
    }
    return result
  }
}
