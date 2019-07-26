//
//  Compiler.swift
//  GodBolt
//
//  Created by Robert Widmann on 7/24/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

public struct Compiler: Codable {
  public let id: String
  public let name: String
  public let language: String

  enum CodingKeys: String, CodingKey {
    case id = "id"
    case name = "name"
    case language = "lang"
  }
}
