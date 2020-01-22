//
//  GodBoltRequest.swift
//  GodBolt
//
//  Created by Sergej Jaskiewicz on 21.01.2020.
//  Copyright © 2020 CodaFi. All rights reserved.
//

import Foundation
import Hammond

public protocol GodBoltRequest: DecodableRequestProtocol
  where ServerError == GodBolt.ServerError, ResponseBody == Data
{
  associatedtype RequestBody = Void

  var testData: (HTTPStatusCode, Data) { get }

  var body: RequestBody { get }

  func encodeBody() throws -> Data?
}

extension GodBoltRequest where RequestBody == Void {
  var body: Void { () }
  func encodeBody() -> Data? { nil }
}

extension GodBoltRequest where RequestBody: Encodable {
  func encodeBody() throws -> Data? {
    try JSONEncoder().encode(body)
  }
}

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
