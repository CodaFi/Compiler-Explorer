//
//  ServerError.swift
//  GodBolt
//
//  Created by Sergej Jaskiewicz on 21.01.2020.
//  Copyright © 2020 CodaFi. All rights reserved.
//

import Foundation
import Hammond

struct ServerError: ServerErrorProtocol, CustomStringConvertible, Decodable {

  let description: String

  static func defaultError(for statusCode: HTTPStatusCode) -> ServerError {
    return .init(description: HTTPURLResponse.localizedString(forStatusCode: statusCode.rawValue))
  }
}

extension ServerError: LocalizedError {
  var errorDescription: String? { description }
}
