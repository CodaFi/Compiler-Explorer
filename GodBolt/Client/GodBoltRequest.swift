//
//  GodBoltRequest.swift
//  GodBolt
//
//  Created by Sergej Jaskiewicz on 21.01.2020.
//  Copyright © 2020 CodaFi. All rights reserved.
//

import Foundation
import Hammond

protocol GodBoltRequest: DecodableRequestProtocol
  where ServerError == GodBolt.ServerError, ResponseBody == Data {}

extension GodBoltRequest {
  static func deserializeError(from body: Data) throws -> GodBolt.ServerError {
    try JSONDecoder().decode(ServerError.self, from: body)
  }
}

extension GodBoltRequest where Result: Decodable {
  static func deserializeResult(from body: Data) throws -> Result {
    try JSONDecoder().decode(Result.self, from: body)
  }
}