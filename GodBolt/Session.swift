//
//  Session.swift
//  GodBolt
//
//  Created by Robert Widmann on 7/26/19.
//  Copyright © 2019 CodaFi. All rights reserved.
//

public struct SessionContainer: Codable {
  public struct SessionCompiler: Codable {
    public let id: String
    public let options: String
    public let filters: Source.Options.Filter
    public let libs: [String]
    public let specialoutputs: [String]
    public let tools: [String]
  }

  public struct Session: Codable {
    public let id: Int
    public let language: String
    public let source: String
    public let conformanceview: Bool
    public let compilers: [SessionCompiler]
  }
  public let sessions: [Session]
}
