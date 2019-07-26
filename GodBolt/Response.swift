//
//  Response.swift
//  GodBolt
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

public struct Text: Codable {
  public let text: String
}

public struct Response: Codable {
  public let code: Int32
  public let stderr: [Text]
  public let asm: [Text]
}
