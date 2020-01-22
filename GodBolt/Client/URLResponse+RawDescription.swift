//
//  URLResponse+RawDescription.swift
//  Compiler-Explorer
//
//  Created by Sergej Jaskiewicz on 22.01.2020.
//

import Foundation
import Hammond

extension URLResponse {
  var rawDescription: String {
    var result = ""
    print(url ?? "(null)", to: &result)
    guard let httpResponse = self as? HTTPURLResponse else { return result }
    print(httpResponse.statusCode, HTTPStatusCode(rawValue: httpResponse.statusCode), to: &result)
    for (key, value) in httpResponse.allHeaderFields {
      print("\(key.base): \(value)", to: &result)
    }
    return result
  }
}
