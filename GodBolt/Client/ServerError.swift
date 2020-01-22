//
//  ServerError.swift
//  GodBolt
//
//  Created by Sergej Jaskiewicz on 21.01.2020.
//  Copyright © 2020 CodaFi. All rights reserved.
//

import Foundation
import Hammond

public struct ServerError: ServerErrorProtocol, CustomStringConvertible, Decodable {

  public let description: String

  public static func defaultError(for statusCode: HTTPStatusCode) -> ServerError {
    return .init(description: HTTPURLResponse.localizedString(forStatusCode: statusCode.rawValue))
  }
}

extension ServerError: LocalizedError {
  public var errorDescription: String? { description }
}
