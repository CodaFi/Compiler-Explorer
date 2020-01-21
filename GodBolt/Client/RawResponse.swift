//
//  RawResponse.swift
//  GodBolt
//
//  Created by Sergej Jaskiewicz on 21.01.2020.
//  Copyright © 2020 CodaFi. All rights reserved.
//

import Hammond
import Foundation

struct RawResponse: ResponseProtocol {
  var body: Data
  var statusCode: HTTPStatusCode
}
